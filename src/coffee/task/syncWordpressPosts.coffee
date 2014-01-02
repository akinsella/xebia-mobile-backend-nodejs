logger = require 'winston'
async = require 'async'
moment = require "moment"
request = require "request"
_ = require('underscore')._

config = require "../conf/config"

utils = require '../lib/utils'
apns = require "../lib/apns"
db = require "../db"
postTransformer = require "../transformer/postTransformer"
News = require "../model/news"
Tag = require "../model/tag"
Category = require "../model/category"
Author = require "../model/author"
Post = require "../model/post"
DetailedPost = require "../model/detailedPost"

synchronize = () ->
	callback = (err, results) ->
		if err
			logger.info "Wordpress Synchronization of blog posts ended with error: #{err.message} - Error: #{err}"
		else
			logger.info "Wordpress Synchronization of blog posts ended with success ! Post Ids: #{results}"

	if config.feature.stopWatch
		callback = utils.stopWatchCallbak callback

	logger.info "Start synchronizing Wordpress data ..."

	processWordpressRecentBlogPosts(1, callback, [])

processWordpressRecentBlogPosts = (page, callback, results) ->
	logger.info "Start synchronizing Wordpress blog posts for page: #{page} ..."
	request.get {url: "http://blog.xebia.fr/wp-json-api/get_recent_posts?count=25&page=#{page}", json: true}, (error, data, response) ->
		async.map response.posts, synchronizeWordpressPost, (err, postIds) ->
			logger.info "Synchronized #{results.length} Wordpress posts for page: #{page}. Post Ids: #{postIds}"

			async.map postIds, synchronizeWordpressDetailedPost, (err, detailedPostIds) ->
				if err
					logger.info "Wordpress Synchronization ended with error: #{err.message} - Error: #{err}"
				else
					logger.info "Wordpress Synchronization of blog posts ended with success ! Detailed Post Ids: #{detailedPostIds}"

				logger.info("Page: #{page}, pages: #{response.pages}")
				if page < response.pages
					results.push(detailedPostIds)
					process.nextTick () ->
						processWordpressRecentBlogPosts(page + 1, callback, results)
				else
					callback(undefined, results)


synchronizeWordpressPost = (post, callback) ->
	logger.info "Checking for post with id: '#{post.id}'"
	Post.findOne { id: post.id }, (err, foundPost) ->
		if err
			callback err, post.id
		else if !foundPost
			postTransformer.transformPost post, (err, post) ->
				if err
					callback err, post.id
				else
					postEntry = new Post(post)
					postEntry.save (err) ->
						callback err, postEntry.id
						if !err
							logger.info "Saved detailed post with id: '#{postEntry.id}'"
		else
			callback err, foundPost.id


synchronizeWordpressDetailedPost = (postId, callback) ->
	logger.info "Checking for detailed post with id: '#{postId}'"
	DetailedPost.findOne { id: postId }, (err, foundDetailedPost) ->
		if err
			callback err
		else if !foundDetailedPost
			request.get {url: "http://blog.xebia.fr/wp-json-api/get_post?post_id=#{postId}", json: true}, (error, data, response) ->
				if err
					callback err, postId
				else if !response
					callback new Error("No detailed post with id: #{postId}")
				else
					detailedPost = response.post
					postTransformer.transformPost detailedPost, (err, detailedPost) ->
						if err
							callback err, response.post.id
						else
							detailedPostEntry = new DetailedPost(detailedPost)
							detailedPostEntry.save (err) ->
								callback err, detailedPostEntry.id
								if !err
									logger.info "Saved detailed post with id: '#{detailedPostEntry.id}'"
									apns.pushToAll "#{detailedPostEntry.title}", () ->
										logger.info "Pushed Notification for blog post with id: '#{detailedPostEntry.id}' and title: '#{detailedPostEntry.title}'"
		else
			callback err, foundDetailedPost.id

module.exports =
	synchronize: synchronize
