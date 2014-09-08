logger = require 'winston'
async = require 'async'
moment = require "moment"
request = require "request"
_ = require('underscore')._

config = require "../conf/config"

utils = require '../lib/utils'
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

			filteredPostIds = postIds.filter((postId) -> postId != undefined)
			async.map filteredPostIds, synchronizeWordpressDetailedPost, (err, detailedPostIds) ->
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

	if post.co_authors.length == 0
		logger.info "Skipping post with id: '#{post.id}', no co-authors"
		callback()
	else
		async.waterfall [
			(cb) ->
				Post.findOne { id: post.id }, cb

			(foundPost, cb) ->
				if foundPost && foundPost.coAuthors.length == 0
					foundPost.remove cb
				else
					cb(undefined, undefined)

			(removedPost, cb) ->
				if !removedPost
					cb(undefined, undefined)
				else
					postTransformer.transformPost post, (err, transformedPost) ->
						if err
							cb(err, undefined)
						else
							postEntry = new Post(transformedPost)
							postEntry.save (err) ->
								cb(err, postEntry.id)
								if !err
									logger.info "Updated post co-authors with id: '#{postEntry.id}'"

		], callback


synchronizeWordpressDetailedPost = (postId, callback) ->
	logger.info "Checking for detailed post with id: '#{postId}'"

	async.waterfall [
		(cb) ->
			DetailedPost.findOne { id: postId }, cb

		(foundDetailedPost, cb) ->
			if foundDetailedPost
				foundDetailedPost.remove cb
			else
				cb(undefined, undefined)

		(removedDetailedPost, cb) ->
			if !removedDetailedPost
				cb(undefined, undefined)
			else
				request.get {url: "http://blog.xebia.fr/wp-json-api/get_post?post_id=#{postId}", json: true}, (error, data, response) ->
					if error
						cb(error, undefined)
					else if !response
						cb(new Error("No detailed post with id: #{postId}"), undefined)
					else
						detailedPost = response.post
						postTransformer.transformPost detailedPost, (err, detailedPost) ->
							if err
								cb(err, undefined)
							else
								detailedPostEntry = new DetailedPost(detailedPost)
								detailedPostEntry.save (err) ->
									cb(err, detailedPostEntry.id)
									if !err
										logger.info "Updated detailed post co-authors with id: '#{detailedPostEntry.id}'"

	], callback


module.exports =
	synchronize: synchronize
