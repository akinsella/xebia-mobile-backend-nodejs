async = require 'async'
request = require "request"
moment = require "moment"
_ = require('underscore')._

config = require "../conf/config"
utils = require '../lib/utils'
db = require "../db"
News = require "../model/news"

synchronize = () ->
	callback = (err, news) ->
		if err
			console.log "Wordpress Synchronization ended with error: #{err.message} - Error: #{err}"
		else
			console.log "Wordpress Synchronization ended with success ! (#{news.length} blog posts synchronized)"

	if config.feature.stopWatch
		callback = utils.stopWatchCallbak callback

	console.log "Start synchronizing Wordpress blog post entries ..."

	processWordpressRecentBlogPosts(callback)

processWordpressRecentBlogPosts = (callback) ->
	request.get {url: "http://blog.xebia.fr/wp-json-api/get_recent_posts?count=50", json: true}, (error, data, response) ->
		async.map response.posts, synchronizeWordpressNews, callback


synchronizeWordpressNews = (post, callback) ->
	News.findOne { type: 'wordpress', typeId: post.id }, (err, news) ->
		if err
			callback err
		else if !news

			newsEntry = new News(
				content: post.excerpt
				draft: false
				imageUrl: if post?.attachments && post.attachments.length > 0 then (post?.attachments[0].images?.full?.url || "") else ""
				publicationDate: post.date
				targetUrl: post.url
				title: post.title_plain
				author: post.author.name
				type: "wordpress"
				typeId: post.id
			)

			newsEntry.save (err) ->
				callback err, newsEntry
		else
			callback err, undefined


module.exports =
	synchronize: synchronize
