utils = require '../lib/utils'
_ = require('underscore')._
jsdom = require 'jsdom'
async = require 'async'
fs = require 'fs'
config = require '../conf/config'
Tag = require '../model/tag'
Category = require '../model/category'
Author = require '../model/author'
Post = require '../model/post'

Array::insertArrayAt = (index, arrayToInsert) ->
	Array.prototype.splice.apply(this, [index, 0].concat(arrayToInsert))
	this

Array::insertAt = (index) ->
	arrayToInsert = Array.prototype.splice.apply(arguments, [1])
	Array.insertArrayAt(index, arrayToInsert)

Array::removeAt = (index) ->
	this.splice(index, 1)

baseUrl = "http://blog.xebia.fr"
#baseUrl = "http://localhost/wordpress"

# To be refactored
processRequest = (req, res, url, transform) ->
	res.charset = "UTF-8"
	options = utils.buildOptions req, res, url, 5 * 60, transform
	utils.processRequest options

authors = (req, res) ->
	Author.find({}).sort("name").exec (err, authors) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			authors = authors.map (author) ->
				author = author.toObject()
				delete author.__v
				delete author._id
				author
			res.json authors

tags = (req, res) ->
	Tag.find({}).sort("title").exec (err, tags) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			tags = tags.map (tag) ->
				tag = tag.toObject()
				delete tag.__v
				delete tag._id
				tag
			res.json tags

categories = (req, res) ->
	Category.find({}).sort("title").exec (err, categories) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			categories = categories.map (category) ->
				category = category.toObject()
				delete category.__v
				delete category._id
				category
			res.json categories

dates = (req, res) ->
	processRequest req, res, "#{baseUrl}/wp-json-api/get_date_index?count=1000", (data, cb) ->
		delete data.status
		delete data.permalinks
		for key, value of data.tree
			data[key] = value
		delete data.tree
		cb(undefined, data)

post = (req, res) ->
	postId = req.params.id
	Post.findOne { id: postId}, (err, post) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else if !post
			res.json 404, { message: "Not Found" }
		else
			post = post.toObject()
			delete post._id
			delete post.__v
			post.tags.forEach (tag) -> delete tag._id
			post.categories.forEach (category) -> delete category._id
			res.json {
				post: post
			}

recentPosts = (req, res) ->
	if config.offlineMode
		res.charset = 'UTF-8'
		payload = JSON.parse(fs.readFileSync("#{__dirname}/../data/wp_recent_post.json", "utf-8"))
		res.send payload
	else
		limit = 50
		Post.count({}, (error, count) ->
			total = count
			pages = if total % 50 == 0 then total / limit else total / limit + 1
			Post.find({}).sort("-date").limit(limit).exec (err, posts) ->
				if err
					res.json 500, { message: "Server error: #{err.message}" }
				else
					res.json {
						count:limit
						pages:pages
						total:total
						posts:posts
					}
		)

authorPosts = (req, res) ->
	authorId = req.params.id
	Post.find({"author.id":Number(authorId)}).sort("-date").exec (err, posts) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			res.json {
				posts:posts
			}

tagPosts = (req, res) ->
	tagId = req.params.id
	Post.find({"tags.id":Number(tagId)}).sort("-date").exec (err, posts) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			res.json {
				posts:posts
			}

categoryPosts = (req, res) ->
	categoryId = req.params.id
	Post.find({"categories.id":Number(categoryId)}).sort("-date").exec (err, posts) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			res.json {
				posts:posts
			}

datePosts = (req, res) ->
	year = req.params.year
	month = req.params.month
	processRequest req, res, "#{baseUrl}/wp-json-api/get_date_posts_sync_data/?date=#{year}#{month}$&count=1000"

module.exports =
	tags : tags,
	categories : categories,
	authors : authors,
	dates : dates,
	recentPosts: recentPosts,
	post : post,
	authorPosts : authorPosts,
	tagPosts : tagPosts,
	categoryPosts : categoryPosts,
	datePosts : datePosts
