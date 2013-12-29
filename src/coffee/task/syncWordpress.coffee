async = require 'async'
moment = require "moment"
_ = require('underscore')._
request = require "request"

config = require "../conf/config"

utils = require '../lib/utils'
db = require "."

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
		tags = _(response.tags).sortBy((tag) -> tag.title.toUpperCase())
		async.map tags, synchronizeWordpressTag, (err, results) ->
			console.log "Synchronized #{results.length} Wordpress tags"

processWordpressCategories = (callback) ->
	console.log "Start synchronizing Wordpress categories ..."
	request.get {url: "http://blog.xebia.fr/wp-json-api/get_category_index", json: true}, (error, data, response) ->
		categories = _(response.categories).sortBy( (category) -> category.title.toUpperCase())
		async.map categories, synchronizeWordpressCategory, (err, results) ->
			console.log "Synchronized #{results.length} Wordpress categories"

processWordpressAuthors = (callback) ->
	console.log "Start synchronizing Wordpress authors ..."
	request.get {url: "http://blog.xebia.fr/wp-json-api/get_author_index", json: true}, (error, data, response) ->
		authors = _(response.authors).sortBy((author) -> author.name.toUpperCase())
		async.map authors, synchronizeWordpressAuthor, (err, results) ->
			console.log "Synchronized #{results.length} Wordpress authors"


synchronizeWordpressTag = (tag, callback) ->
	Tag.findOne { id: tag.id }, (err, tagFound) ->
		if err
			callback err
		else if !tagFound
			tag.postCount = tag.post_count
			delete tag.post_count
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
			category.postCount = category.post_count
			delete category.post_count
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
			author.firstName = author.first_name
			delete author.first_name
			author.lastName = author.last_name
			delete author.last_name
			authorEntry = new Author(author)
			authorEntry.save (err) ->
				callback err, authorEntry.id
				console.log("New author synchronised: #{authorEntry.name}")
		else
			callback err, authorFound.id

module.exports =
	synchronize: synchronize
