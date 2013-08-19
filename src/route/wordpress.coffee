fs = require "fs"
utils = require '../lib/utils'
_ = require('underscore')._
jsdom = require 'jsdom'
async = require 'async'

#jquery = fs.readFileSync "./lib/jquery.js", "utf-8"

baseUrl = "http://blog.xebia.fr"
#baseUrl = "http://localhost/wordpress"

# To be refactored
processRequest = (req, res, url, transform) ->
	res.charset = "UTF-8"
	options = utils.buildOptions req, res, url, 5 * 60, transform
	utils.processRequest options

	return


# To be refactored
#wildcard = (req, res) ->
#	processRequest req, res, "http://blog.xebia.fr/wp-json-api/" + utils.getUrlToFetch(req).substring("/api/wordpress/".length)


authors = (req, res) ->
	# utils.getUrlToFetch(req).substring("/api/wordpress/authors".length)
	processRequest req, res, "#{baseUrl}/wp-json-api/get_author_index?count=250", (data, cb) ->
			delete data.status
			_(data.authors).each (author) ->
				author.firstname = author.first_name
				delete author.first_name
				author.lastname = author.last_name
				delete author.last_name
				return
			cb(data)


tags = (req, res) ->
	# utils.getUrlToFetch(req).substring("/api/wordpress/tags".length)
	processRequest req, res, "#{baseUrl}/wp-json-api/get_tag_index/?count=2000", (data, cb) ->
		delete data.status
		_(data.tags).each (tag) ->
			tag.postCount = tag.post_count
			delete tag.post_count
			return
		cb(data)


categories = (req, res) ->
	# utils.getUrlToFetch(req).substring("/api/wordpress/categories".length)
	processRequest req, res, "#{baseUrl}/wp-json-api/get_category_index?count=100", (data, cb) ->
		delete data.status
		_(data.categories).each (category) ->
			category.postCount = category.post_count
			delete category.post_count
			return
		cb(data)


dates = (req, res) ->
	# utils.getUrlToFetch(req).substring("/api/wordpress/categories".length)
	processRequest req, res, "#{baseUrl}/wp-json-api/get_date_index?count=1000", (data, cb) ->
		delete data.status
		delete data.permalinks
		for key, value of data.tree
			data[key] = value
		delete data.tree

		cb(data)


post = (req, res) ->
	postId = req.params.id
	processRequest req, res, "#{baseUrl}/wp-json-api/get_post?post_id=#{postId}", (data, cb) ->
		delete data.status
		delete data.previous_url
		delete data.next_url
		transformPost(data.post, (err, post) ->
			if !err && post
				data.post = post
			cb(err, data)
		)


recentPosts = (req, res) ->
	processRequest req, res, "#{baseUrl}/wp-json-api/get_recent_posts", (data, cb) ->
		delete data.status
		data.total = data.count_total
		delete data.count_total
		async.map(data.posts, transformPost, (err, posts) ->
			cb(data)
		)

authorPosts = (req, res) ->
	authorId = req.params.id
	processRequest req, res, "#{baseUrl}/wp-json-api/get_author_posts?id=#{authorId}", (data, cb) ->
		_(data.posts).each (post) ->
			transformPost(post)
		cb(data)


tagPosts = (req, res) ->
	tagId = req.params.id
	processRequest req, res, "#{baseUrl}/wp-json-api/get_tag_posts?id=#{tagId}", (data, cb) ->
		_(data.posts).each (post) ->
			transformPost(post)
		cb(data)


categoryPosts = (req, res) ->
	categoryId = req.params.id
	processRequest req, res, "#{baseUrl}/wp-json-api/get_category_posts?id=#{categoryId}", (data, cb) ->
		_(data.posts).each (post) ->
			transformPost(post)
		cb(data)


datePosts = (req, res) ->
	year = req.params.year
	month = req.params.month
	processRequest req, res, "#{baseUrl}/wp-json-api/get_date_posts_sync_data/?date=#{year}#{month}$&count=1000"



transformPost = (post, cb) ->
	post.titlePlain = post.title_plain
	delete post.title_plain
	post.commentCount = post.comment_count
	delete post.comment_count
	post.commentStatus = post.comment_status
	delete post.comment_status
	delete post.title_plain
	_(post.categories).each (category) ->
		category.postCount = category.post_count
		delete category.post_count
	_(post.tags).each (tag) ->
		tag.postCount = tag.post_count
		delete tag.post_count
	post.authors = [post.author]
	delete post.author
	_(post.authors).each (author) ->
		author.firstname = author.first_name
		delete author.firstname
		author.lastname = author.last_name
		delete author.last_name
	_(post.comments).each (author) ->
		delete author.parent
	transformPostContent(post, cb)


transformPostContent = (post, cb) ->
#	[author twitter="@bmoussaud" username="bmoussaud" urls="http://github.com/user" gravatar="bmoussaud@xebialabs.com" lastname="Moussaud" firstname="Benoit"/]

	matches = post.content.match(/\[author.*\]/g)
	console.log "Matches: #{matches}"

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


	languages = [ "java" ]
	for language in languages
		post.content = post.content.replace(/\[java\]/g, "<code language=\"#{language}\">")
		post.content = post.content.replace(/\[\/java\]/g, "</code>")


	jsdom.env
		html: post.content,
		src: [],
#		src: [jquery],
		done: (err, window) ->
			if (err)
				cb(err)
			else
				document = window.document.body
				restructureElement(document)
				async.map document.childNodes, mapElement, (err, children) ->
					if !err && children
						post.structuredContent = mergeSiblingTexts(filterEmptyChildren(children))
					cb(err, post)
					window.close()

restructureElement = (element) ->
	children = []
	for child in element.childNodes
		children.push child
	if element.tagName in [ "A", "LI", "SPAN" ]
		element.removeAttribute "class"
	if element.tagName == "DIV"
		if element.parentNode.tagName == "LI" && element.parentNode.childNodes.length == 1
			for child in children
				element.removeChild child
				element.parentNode.insertBefore child, element
			element.parentNode.removeChild element
#	if element.tagName == "IMG"
#		if element.parentNode.tagName == "A" && element.parentNode.childNodes.length == 1
#			element.parentNode.parentNode.insertBefore element, element.parentNode
#			element.attributes.href = element.parentNode.attributes.href
#			element.parentNode.parentNode.removeChild element.parentNode
#			element.parentNode.removeChild element
	for child in children
		restructureElement(child)

mapElement = (element, cb) ->
	if element.nodeName == "#text"
		cb(undefined, {
			type: "#text"
			text: element.nodeValue
		})
	else if element.tagName == "IMG"
		image = {
			type: "img",
			src: element.src
			text: element.outerHTML
		}
		if element.attributes.href
			image.href = element.attributes.href
		cb(undefined, image)
	else if element.tagName == "AUTHOR"
		cb(undefined, {
			type: "author",
			username: element.attributes.username.value
			firstname: element.attributes.firstname.value
			lastname: element.attributes.lastname.value
			gravatar: element.attributes.gravatar.value
			twitter: element.attributes.twitter.value
		})
	else if element.tagName == "CODE"
		cb(undefined, {
			type: "code",
			language: element.attributes.language.value,
			text: element.innerHTML
		})
	else if element.tagName == "A"
		if areChildNodesTextOnly(element.childNodes)
			cb(undefined, {
				type: "a"
				text: element.outerHTML
			})
		else
			async.map element.childNodes, mapElement, (err, children) ->
				cb(undefined, {
					type: "a",
					children: mergeSiblingTexts(filterEmptyChildren(children))
				})
	else if element.tagName == "DIV"
		if areChildNodesTextOnly(element.childNodes)
			cb(undefined, {
				type: "p"
				text: "<p>#{element.innerHTML}</p>"
			})
		else
			async.map element.childNodes, mapElement, (err, children) ->
				cb(undefined, {
					type: "div",
					children: mergeSiblingTexts(filterEmptyChildren(children))
				})
	else if element.tagName == "P"
		if areChildNodesTextOnly(element.childNodes)
			cb(undefined, {
				type: "p"
				text: "<p>#{element.innerHTML}</p>"
			})
		else
			async.map element.childNodes, mapElement, (err, children) ->
				cb(undefined, {
					type: "p",
					children: mergeSiblingTexts(filterEmptyChildren(children))
				})
	else if element.tagName == "SPAN"
		if areChildNodesTextOnly(element.childNodes)
			cb(undefined, {
				type: "span"
				ignore: element.innerHTML.trim().length == 0
				text: element.outerHTML
			})
		else
			async.map element.childNodes, mapElement, (err, children) ->
				cb(undefined, {
					type: "span",
					children: mergeSiblingTexts(filterEmptyChildren(children))
				})
	else if element.tagName == "EM"
		if areChildNodesTextOnly(element.childNodes)
			cb(undefined, {
				type: "em"
				text: "<em>#{element.innerHTML}</em>"
			})
		else
			async.map element.childNodes, mapElement, (err, children) ->
				cb(undefined, {
					type: "em",
					children: mergeSiblingTexts(filterEmptyChildren(children))
				})
	else if element.tagName == "STRONG"
		if areChildNodesTextOnly(element.childNodes)
			cb(undefined, {
				type: "em"
				text: "<em>#{element.innerHTML}</em>"
			})
		else
			async.map element.childNodes, mapElement, (err, children) ->
				cb(undefined, {
					type: "em",
					children: mergeSiblingTexts(filterEmptyChildren(children))
				})
	else if element.tagName == "H1"
		cb(undefined, {
			type: "h1",
			text: element.innerHTML
		})
	else if element.tagName == "H2"
		cb(undefined, {
			type: "h2",
			text: element.innerHTML
		})
	else if element.tagName == "H3"
		cb(undefined, {
			type: "h3",
			text: element.innerHTML
		})
	else if element.tagName == "H4"
		cb(undefined, {
			type: "h4",
			text: element.innerHTML
		})
	else if element.tagName == "H5"
		cb(undefined, {
			type: "h4",
			text: element.innerHTML
		})
	else if element.tagName == "H6"
		cb(undefined, {
			type: "h6",
			text: element.innerHTML
		})
	else if element.tagName == "UL"
		if areChildNodesTextOnly(element.childNodes)
			cb(undefined, {
				type: "ul"
				text: "<ul>#{element.innerHTML}</ul>"
			})
		else
			async.map element.childNodes, mapElement, (err, children) ->
				cb(undefined, {
					type: "ul",
					children: mergeSiblingTexts(filterEmptyChildren(children))
				})
	else if element.tagName == "OL"
		if areChildNodesTextOnly(element.childNodes)
			cb(undefined, {
				type: "ol"
				text: "<ol>#{element.innerHTML}</ol>"
			})
		else
			async.map element.childNodes, mapElement, (err, children) ->
				cb(undefined, {
					type: "ol",
					children: mergeSiblingTexts(filterEmptyChildren(children))
				})
	else if element.tagName == "LI"
		if areChildNodesTextOnly(element.childNodes)
			cb(undefined, {
				type: "li"
				text: "<li>#{element.innerHTML}</li>"
			})
		else
			async.map element.childNodes, mapElement, (err, children) ->
				cb(undefined, {
					type: "li",
					children: mergeSiblingTexts(filterEmptyChildren(children))
				})
	else
		cb(undefined, {
			type: element.tagName.toLowerCase(),
			text: element.innerHTML
		})

mergeSiblingTexts = (children) ->
	newChildren = []
	text = ""
	index = 0
	for child in children
		index++
		if  !child.children && child.text && child.type in ["#text", "p", "span", "em", "a", "ul", "ol", "li", "strong", "em"]
			text = "#{text}#{child.text}"
		else
			if text.length > 0
				newChildren.push({
					type: "#text",
					text: text.trim()
				})
			text = ""
			newChildren.push(child)
	if text.length > 0
		newChildren.push({
			type: "#text",
			text: text
		})
	newChildren

areChildNodesTextOnly = (childNodes) ->
	if !childNodes
		return true
	for childNode in childNodes
		if childNode.tagName in ["VIDEO", "IMG", "CODE"] || !areChildNodesTextOnly(childNode.childNodes)
			return false
	return true

filterEmptyChildren = (children) ->
	_(children).filter (child) ->
		if child.ignore
			false
		else
			child.children || child.text == undefined || child.text.trim().length > 0


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
