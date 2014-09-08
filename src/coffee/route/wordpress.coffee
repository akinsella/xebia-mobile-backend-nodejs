fs = require 'fs'
_ = require 'underscore'

config = require '../conf/config'
utils = require '../lib/utils'

Tag = require '../model/tag'
Category = require '../model/category'
Author = require '../model/author'
Post = require '../model/post'
DetailedPost = require '../model/detailedPost'

baseUrl = "http://blog.xebia.fr"

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

post = (req, res) ->
	postId = req.params.id
	DetailedPost.findOne { id: postId}, (err, post) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else if !post
			res.json 404, { message: "Not Found" }
		else
			res.json
				post: cleanUpPost(post)


cleanUpPost = (post) ->
	post = post.toObject()
	delete post._id
	delete post.__v
	post.tags.forEach (tag) -> delete tag._id
	post.categories.forEach (category) -> delete category._id

	post.authors.forEach (author) -> delete author._id
	if post.coAuthors
		post.coAuthors = _(post.coAuthors).filter (author) -> author != null
		post.coAuthors.forEach (author) ->
			if author
				delete author._id
	else
		post.coAuthors = []
	post.attachments.forEach (attachment) -> delete attachment._id
	post.comments.forEach (comment) -> delete comment._id
	if post.structuredContent
		post.structuredContent.forEach (scItem) ->
			if scItem.attributes
				scItem.attributes.forEach (attribute) ->
					delete attribute._id
			delete scItem._id
	post

recentPosts = (req, res) ->
	if config.offlineMode
		res.charset = 'UTF-8'
		payload = JSON.parse(fs.readFileSync("#{__dirname}/../data/offline/wp_recent_post.json", "utf-8"))
		res.send payload
	else
		page =  if utils.isNumber(req.params.page) then req.params.page - 1 else 0
		page = Math.floor(page)
		page = Math.max(0, page)

		limit = if utils.isNumber(req.query.limit) then req.query.limit else 50
		limit = Math.floor(limit)
		limit = Math.max(limit, 10)
		limit = Math.min(limit, 10000)

		Post.count({}, (error, count) ->
			total = count
			pages = total / limit
			pages = Math.ceil(pages)
			Post.find({}).sort("-date").skip(limit * page).limit(limit).exec (err, posts) ->
				if err
					res.json 500, { message: "Server error: #{err.message}" }
				else
					posts = posts.map (post) ->
						post = cleanUpPost(post)
						delete post.comments
						delete post.attachments
						post
					res.json
						page:page + 1
						count:limit
						pages:pages
						total:total
						posts:posts
		)

authorPosts = (req, res) ->
	authorId = req.params.id
	Post.find({"author.id":Number(authorId)}).sort("-date").exec (err, posts) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			posts = posts.map (post) -> cleanUpPost(post)
			res.json
				posts:posts

tagPosts = (req, res) ->
	tagId = req.params.id
	Post.find({"tags.id":Number(tagId)}).sort("-date").exec (err, posts) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			posts = posts.map (post) -> cleanUpPost(post)
			res.json
				posts:posts

categoryPosts = (req, res) ->
	categoryId = req.params.id
	Post.find({"categories.id":Number(categoryId)}).sort("-date").exec (err, posts) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			posts = posts.map (post) -> cleanUpPost(post)
			res.json
				posts:posts

module.exports =
	tags : tags
	categories : categories
	authors : authors
	recentPosts: recentPosts
	post : post
	authorPosts : authorPosts
	tagPosts : tagPosts
	categoryPosts : categoryPosts
