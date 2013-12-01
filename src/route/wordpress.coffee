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
	Author.find {}, (err, authors) ->
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
	Tag.find {}, (err, tags) ->
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
	Category.find {}, (err, categories) ->
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
					async.map(posts, transformPost, (err, posts) ->
						res.json {
							count:limit
							pages:pages
							total:total
							posts:posts
						}
					)
		)

authorPosts = (req, res) ->
	authorId = req.params.id
	Post.find({}).where("author.id").equals(authorId).sort("-date").exec (err, posts) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			async.map(posts, transformPost, (err, posts) ->
				res.json {
					posts:posts
				}
			)

tagPosts = (req, res) ->
	tagId = req.params.id
	Post.find({}).where("tag.id").equals(tagId).sort("-date").exec (err, posts) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			async.map(posts, transformPost, (err, posts) ->
				res.json {
					posts:posts
				}
			)

categoryPosts = (req, res) ->
	categoryId = req.params.id
	Post.find({}).where("category.id").equals(categoryId).sort("-date").exec (err, posts) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			async.map(posts, transformPost, (err, posts) ->
				res.json {
					posts:posts
				}
			)

datePosts = (req, res) ->
	year = req.params.year
	month = req.params.month
	processRequest req, res, "#{baseUrl}/wp-json-api/get_date_posts_sync_data/?date=#{year}#{month}$&count=1000"


transformPost = (post, cb) ->
	post = post.toObject()
	delete post.__v
	delete post._id
	post.titlePlain = post.title_plain
	delete post.title_plain
	post.commentCount = post.comment_count
	delete post.comment_count
	post.commentStatus = post.comment_status
	delete post.comment_status
	for category in post.categories
		category.postCount = category.post_count
		delete category.post_count
		delete category.__v
		delete category._id
	for tag in post.tags
		tag.postCount = tag.post_count
		delete tag.post_count
		delete tag.__v
		delete tag._id
	post.authors = [post.author]
	delete post.author
	for author in post.authors
		author.firstname = author.first_name
		delete author.firstname
		author.lastname = author.last_name
		delete author.last_name
		delete author.__v
		delete author._id
	for comment in post.comments
		delete comment.parent
		delete comment.__v
		delete comment._id
	for attachment in post.attachments
		delete attachment.__v
		delete attachment._id
	transformPostContent(post, cb)


transformPostContent = (post, cb) ->
#	[author twitter="@bmoussaud" username="bmoussaud" urls="http://github.com/user" gravatar="bmoussaud@xebialabs.com" lastname="Moussaud" firstname="Benoit"/]

	processAuthorInformations(post)
	processLanguageInformations(post)

	jsdom.env
		html: post.content,
		src: [],
#		src: [jquery],
		done: (err, window) ->
			if (err)
				cb(err)
			else
				try
					post.structuredContent = cleanUpAttributes(processTextElements(mergeSiblingTexts(stringifyChildren(restructureChildren(filterEmptyChildren(mapChildNodes(window.document.body.childNodes, mapChildNode)))))))
				catch e
					console.log "Got some error: #{e.message}"
					err = e
					console.log( err.stack )
				cb(err, post)
				window.close()

processAuthorInformations = (post) ->
	matches = post.content.match(/\[author.*\]/g)
	#console.log "Matches: #{matches}"

	if matches
		for match in matches
			components = (/\[author.*twitter="(.*)".*username="(.*)".*urls="(.*)".*gravatar="(.*)".*lastname="(.*)".*firstname="(.*)".*\]/).exec(match)
			console.log "Components: #{components}"
			twitter = components[1]
			username = components[2]
	#		urls = components[3]
			gravatar = components[4]
			lastname = components[5]
			firstname = components[6]

			post.content = post.content.replace(match, "<author username=\"#{username}\" firstname=\"#{firstname}\" lastname=\"#{lastname}\" gravatar=\"#{gravatar}\" twitter=\"#{twitter}\" />")

processLanguageInformations = (post) ->
	languages = [ "java", "xml", "javascript", "cpp", "scala", "default" ]
	for language in languages
#		post.content = post.content.replace(/\[(\w+)[^\]]*\](.*?)\[\/\1\]/g, '$2')
		startTag = "\\[#{language}\\]"
		endTag = "\\[\\/#{language}\\]"
		post.content = post.content.replace(new RegExp(startTag, "g"), "<code language=\"#{language}\">")
		post.content = post.content.replace(new RegExp(endTag, "g"), "</code>")


mapChildNodes = (childNodes, mapChildNode) ->
	_(childNodes).map (childNode) -> mapChildNode(childNode)

mapChildNode = (childNode) ->
	element = {
		type: childNode.nodeName,
		attributes: [],
		children: []
	}

	if childNode.childNodes.length
		element.children = mapChildNodes(childNode.childNodes, mapChildNode)
	if childNode.nodeName == "#text"
		element.text = childNode.nodeValue
	else if childNode.nodeName == "IMG"
		element.attributes.push { key: "src", value: childNode.src }
	else if childNode.nodeName == "A"
		element.attributes.push { key: "href", value: childNode.href }
	else if childNode.nodeName == "AUTHOR"
		element.attributes.push { key: "username", value: childNode.attributes.username.value }
		element.attributes.push { key: "firstname", value: childNode.attributes.firstname.value }
		element.attributes.push { key: "lastname", value: childNode.attributes.lastname.value }
		element.attributes.push { key: "gravatar", value: childNode.attributes.gravatar.value }
		element.attributes.push { key: "twitter", value: childNode.attributes.twitter.value }
	else if childNode.nodeName == "CODE"
		element.attributes.push { key: "language", value: if childNode.attributes.language then childNode.attributes.language.value else "default" }


	element.innerHTML = () ->
		if !element.children.length
			element.text
		else
			element.children.map((element) -> element.outerHTML()).reduce (elt1, elt2) -> elt1 + elt2

	element.outerHTML = () ->
		if element.type == "#text"
			"#{element.text}"
		else if element.type in ["IMG"]
			if element.attributes.length > 0
				attributes = ("#{attribute.key}=\"#{attribute.value}\"" for attribute in element.attributes).reduce ((attr1, attr2) -> "#{attr1} #{attr2}"), ""
				"<#{element.type} #{attributes} />"
			else
				"<#{element.type} />"
		else
			if element.attributes.length > 0
				attributes = ("#{attribute.key}=\"#{attribute.value}\"" for attribute in element.attributes).reduce ((attr1, attr2) -> "#{attr1} #{attr2}"), ""
				"<#{element.type} #{attributes}>#{element.innerHTML()}</#{element.type}>"
			else
				"<#{element.type}>#{element.innerHTML()}</#{element.type}>"

	element

restructureChildren = (children) ->
	for child, index in children
		child.children = restructureChildren(child.children)
		if child.type == "DIV"
			children.removeAt(index)
			children.insertArrayAt(index, child.children)

		else if child.type == "A" && child.children.length == 1 && child.children[0].type == "IMG" && !child.text
			child.type = "IMG"
			href = _(child.attributes).find((attribute) -> attribute.key == "href")
			child.attributes = []
			child.attributes.push _(child.children[0].attributes).find((attribute) -> attribute.key == "src")
			child.attributes.push href
			child.children = []

		else if child.type == "P" && child.children.length == 1 && child.children[0].type == "IMG" && !child.text
			child.type = "IMG"
			child.attributes = []
			child.attributes.push _(child.children[0].attributes).find((attribute) -> attribute.key == "src")
			href = _(child.children[0].attributes).find((attribute) -> attribute.key == "href")
			if href
				child.attributes.push _(child.children[0].attributes).find((attribute) -> attribute.key == "href")
			child.children = []
		else if child.type == "CODE" && child.children.length == 1 && child.children[0].type == "A"
			child.type = "A"
			child.attributes = []
			href = _(child.children[0].attributes).find((attribute) -> attribute.key == "href")
			child.attributes.push _(child.children[0].attributes).find((attribute) -> attribute.key == "href")
			child.children = []

	children

processTextElements = (children) ->
	for child in children
		child.children = processTextElements(child.children)
		if child.type == "#text"
			child.type = "P"
	children

filterEmptyChildren = (children) ->
	for child in children
		child.children = filterEmptyChildren(child.children)
	children = children.filter (child) ->
		child.text && child.text.trim() || child.children.length || child.type in ["IMG"]
	children

stringifyChildren = (children) ->
	for child in children
		if child.children.length
			if areChildrenTextOnly(child.children) || child.type in ["TABLE"]
				child.text = child.innerHTML()
				child.children = []
			else
				stringifyChildren(child.children)
	children

cleanUpAttributes = (children) ->
	newChildren = []
	for child in children
		if child.children.length
			cleanUpAttributes(child.children)
		delete child.children
		if child.text || child.type in ["IMG"]
			newChildren.push child
	newChildren

areChildrenTextOnly = (children) ->
	if !children
		return true
	for child in children
		if child.type in ["VIDEO", "IMG", "CODE", "TABLE", "DIV", "H1", "H2", "H3", "H4", "H5", "H6"] || !areChildrenTextOnly(child.children)
			return false
	return true

mergeSiblingTexts = (children) ->
	newChildren = []
	text = ""
	index = 0
	for child in children
		index++
		if !child.children.length && child.type in ["#text", "P", "SPAN", "EM", "A", "LI", "STRONG", "EM", "AUTHOR"]
			text = "#{text}#{child.outerHTML()}"
		else
			if text.length
				newChildren.push({
					type: "#text",
					text: "#{text.trim()}",
					children: []
				})
			text = ""
			newChildren.push(child)
	if text.length
		newChildren.push({
			type: "#text",
			text: "#{text.trim()}",
			children: []
		})
	for child in children
		if child.children.length
			child.children = mergeSiblingTexts(child.children)
	newChildren

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
