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

synchronize = () ->
	callback = (err, results) ->
		if err
			console.log "Wordpress Synchronization ended with error: #{err.message} - Error: #{err}"
		else
			console.log "Wordpress Synchronization ended with success !"

	if config.feature.stopWatch
		callback = utils.stopWatchCallbak callback

	console.log "Start synchronizing Wordpress data ..."

	async.parallel [
		processWordpressTags,
		processWordpressCategories,
		processWordpressAuthors
	], callback

processWordpressTags = (callback) ->
	console.log "Start synchronizing Wordpress tags ..."
	request.get {url: "http://blog.xebia.fr/wp-json-api/get_tag_index", json: true}, (error, data, response) ->
		async.map response.tags, synchronizeWordpressTag, (err, results) ->
			console.log "Synchronized #{results.length} Wordpress tags"

processWordpressCategories = (callback) ->
	console.log "Start synchronizing Wordpress categories ..."
	request.get {url: "http://blog.xebia.fr/wp-json-api/get_category_index", json: true}, (error, data, response) ->
		async.map response.categories, synchronizeWordpressCategory, (err, results) ->
			console.log "Synchronized #{results.length} Wordpress categories"

processWordpressAuthors = (callback) ->
	console.log "Start synchronizing Wordpress authors ..."
	request.get {url: "http://blog.xebia.fr/wp-json-api/get_author_index", json: true}, (error, data, response) ->
		async.map response.authors, synchronizeWordpressAuthor, (err, results) ->
			console.log "Synchronized #{results.length} Wordpress authors"


synchronizeWordpressTag = (tag, callback) ->
	Tag.findOne { id: tag.id }, (err, tagFound) ->
		if err
			callback err
		else if !tagFound

			tagEntry = new Tag(tag)
			tagEntry.save (err) ->
				callback err, tagEntry.id
				console.log("New tag synchronised: #{tagEntry.title}")
		else
			callback err, tagFound.id


synchronizeWordpressCategory = (category, callback) ->
	Category.findOne { id: category.id }, (err, categoryFound) ->
		if err
			callback err
		else if !categoryFound

			categoryEntry = new Category(category)
			categoryEntry.save (err) ->
				callback err, categoryEntry.id
				console.log("New category synchronised: #{categoryEntry.title}")
		else
			callback err, categoryFound.id

synchronizeWordpressAuthor = (author, callback) ->
	Author.findOne { id: author.id }, (err, authorFound) ->
		if err
			callback err
		else if !authorFound

			authorEntry = new Author(author)
			authorEntry.save (err) ->
				callback err, authorEntry.id
				console.log("New author synchronised: #{authorEntry.name}")
		else
			callback err, authorFound.id

module.exports =
	synchronize: synchronize
