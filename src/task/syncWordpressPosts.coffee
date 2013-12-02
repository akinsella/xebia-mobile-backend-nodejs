async = require 'async'
moment = require "moment"
_ = require('underscore')._
request = require "request"

config = require "../conf/config"

utils = require '../lib/utils'
db = require "../db"
apns = require "../lib/apns"

News = require "../model/news"
Tag = require "../model/tag"
Category = require "../model/category"
Author = require "../model/author"
Post = require "../model/post"
DetailedPost = require "../model/detailedPost"
postTransformer = require "../transformer/postTransformer"

synchronize = () ->
	callback = (err, results) ->
		if err
			console.log "Wordpress Synchronization of blog posts ended with error: #{err.message} - Error: #{err}"
		else
			console.log "Wordpress Synchronization of blog posts ended with success ! Post Ids: #{results}"

	if config.feature.stopWatch
		callback = utils.stopWatchCallbak callback

	console.log "Start synchronizing Wordpress data ..."

	processWordpressRecentBlogPosts(1, callback, [])

processWordpressRecentBlogPosts = (page, callback, results) ->
	console.log "Start synchronizing Wordpress blog posts for page: #{page} ..."
	request.get {url: "http://blog.xebia.fr/wp-json-api/get_recent_posts?count=25&page=#{page}", json: true}, (error, data, response) ->
		async.map response.posts, synchronizeWordpressPost, (err, postIds) ->
			console.log "Synchronized #{results.length} Wordpress posts for page: #{page}. Post Ids: #{postIds}"

			async.map postIds, synchronizeWordpressDetailedPost, (err, detailedPostIds) ->
				if err
					console.log "Wordpress Synchronization ended with error: #{err.message} - Error: #{err}"
				else
					console.log "Wordpress Synchronization of blog posts ended with success ! Detailed Post Ids: #{detailedPostIds}"

				console.log("Page: #{page}, pages: #{response.pages}")
				if page < response.pages
					results.push(detailedPostIds)
					process.nextTick () ->
						processWordpressRecentBlogPosts(page + 1, callback, results)
				else
					callback(undefined, results)


synchronizeWordpressPost = (post, callback) ->
	console.log "Checking for post with id: '#{post.id}'"
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
							console.log "Saved detailed post with id: '#{postEntry.id}'"
		else
			callback err, foundPost.id


synchronizeWordpressDetailedPost = (postId, callback) ->
	console.log "Checking for detailed post with id: '#{postId}'"
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
									console.log "Saved detailed post with id: '#{detailedPostEntry.id}'"
									apns.pushToAll "New blog detailed post: #{detailedPostEntry.title}", () ->
										console.log "Pushed Notification for blog post with title: '#{detailedPostEntry.title}'"
		else
			callback err, foundDetailedPost.id

module.exports =
	synchronize: synchronize
