utils = require '../lib/utils'
_ = require('underscore')._

# To be refactored
processRequest = (req, res, url, transform) ->

	options = utils.buildOptions req, res, url, 5 * 60, transform
	utils.processRequest options

	return


# To be refactored
#wildcard = (req, res) ->
#	processRequest req, res, "http://blog.xebia.fr/wp-json-api/" + utils.getUrlToFetch(req).substring("/api/wordpress/".length)


authors = (req, res) ->
	# utils.getUrlToFetch(req).substring("/api/wordpress/authors".length)
	processRequest req, res, "http://blog.xebia.fr/wp-json-api/get_author_index?count=250", (data) ->
			delete data.status
			_(data.authors).each (author) ->
				author.firstname = author.first_name
				delete author.first_name
				author.lastname = author.last_name
				delete author.last_name
				return
			data


tags = (req, res) ->
	# utils.getUrlToFetch(req).substring("/api/wordpress/tags".length)
	processRequest req, res, "http://blog.xebia.fr/wp-json-api/get_tag_index/?count=2000", (data) ->
		delete data.status
		_(data.tags).each (tag) ->
			tag.postCount = tag.post_count
			delete tag.post_count
			return
		data


categories = (req, res) ->
	# utils.getUrlToFetch(req).substring("/api/wordpress/categories".length)
	processRequest req, res, "http://blog.xebia.fr/wp-json-api/get_category_index?count=100", (data) ->
		delete data.status
		_(data.categories).each (category) ->
			category.postCount = category.post_count
			delete category.post_count
			return
		data


dates = (req, res) ->
	# utils.getUrlToFetch(req).substring("/api/wordpress/categories".length)
	processRequest req, res, "http://blog.xebia.fr/wp-json-api/get_date_index?count=1000", (data) ->
		delete data.status
		delete data.permalinks
		for key, value of data.tree
			data[key] = value
		delete data.tree

		data


post = (req, res) ->
	postId = req.params.id
	processRequest req, res, "http://blog.xebia.fr/wp-json-api/get_post?post_id=#{postId}", (data) ->
		delete data.status
		delete data.previous_url
		delete data.next_url
		data.post.titlePlain = data.post.title_plain
		data.post.commentCount = data.post.comment_count
		delete data.post.comment_count
		data.post.commentStatus = data.post.comment_status
		delete data.post.comment_status
		delete data.post.title_plain
		_(data.post.categories).each (category) ->
			category.postCount = category.post_count
			delete category.post_count
		_(data.post.tags).each (tag) ->
			tag.postCount = tag.post_count
			delete tag.post_count
		_(data.post.authors).each (author) ->
			author.firstname = author.first_name
			delete author.firstname
			author.lastname = author.last_name
			delete author.last_name
		_(data.post.comments).each (author) ->
			delete author.parent

		data.post


recentPosts = (req, res) ->
	processRequest req, res, "http://blog.xebia.fr/wp-json-api/get_recent_posts", (data) ->
		delete data.status
		post.total = post.title_plain
		delete post.title_plain
		_(data.posts).each (post) ->
			post.titlePlain = post.title_plain
			delete post.title_plain
			return
		data


authorPosts = (req, res) ->
	authorId = req.params.authorId
	processRequest req, res, "http://blog.xebia.fr/wp-json-api/get_author_posts?id=#{authorId}"


tagPosts = (req, res) ->
	tagId = req.params.tagId
	processRequest req, res, "http://blog.xebia.fr/wp-json-api/get_category_posts?id=#{tagId}"


categoryPosts = (req, res) ->
	categoryId = req.params.categoryId
	processRequest req, res, "http://blog.xebia.fr/wp-json-api/get_category_posts?id=#{categoryId}"


datePosts = (req, res) ->
	year = req.params.year
	month = req.params.month
	processRequest req, res, "http://blog.xebia.fr/wp-json-api/get_date_posts_sync_data/?date=#{year}#{month}$&count=1000"


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
