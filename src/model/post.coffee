mongo = require '../lib/mongo'

Post = new mongo.Schema(
	id: Number,
	type: {type: String, "default": '', trim: true},
	slug: {type: String, "default": '', trim: true},
	url: {type: String, "default": '', trim: true},
	status: {type: String, "default": '', trim: true},
	title: {type: String, "default": '', trim: true},
	title_plain: {type: String, "default": '', trim: true},
	content: {type: String, "default": '', trim: true},
	structuredContent: {type: String, "default": '', trim: true},
	excerpt: {type: String, "default": '', trim: true},
	date: {type: String, "default": '', trim: true},
	modified: {type: String, "default": '', trim: true},
	comment_count: Number,
	comment_status: {type: String, "default": '', trim: true},
	categories: [{
		id: Number,
		parent: Number,
		title: {type: String, "default": '', trim: true},
		slug: {type: String, "default": '', trim: true},
		description: {type: String, "default": '', trim: true},
		post_count: Number
	}],
	tags: [{
		id: Number,
		title: {type: String, "default": '', trim: true},
		slug: {type: String, "default": '', trim: true},
		description: {type: String, "default": '', trim: true},
		post_count: Number
	}],
	authors:[{
		id: Number,
		slug: {type: String, "default": '', trim: true},
		name: {type: String, "default": '', trim: true},
		first_name: {type: String, "default": '', trim: true},
		last_name: {type: String, "default": '', trim: true},
		nickname: {type: String, "default": '', trim: true},
		url: {type: String, "default": '', trim: true},
		description: {type: String, "default": '', trim: true}
	}],
	comments: [{
		id: Number,
		name: {type: String, "default": '', trim: true},
		url: {type: String, "default": '', trim: true},
		date: {type: String, "default": '', trim: true},
		content: {type: String, "default": '', trim: true},
		parent: Number
	}],
	attachments: [{
		id: Number
		url: {type: String, "default": '', trim: true},
		slug: {type: String, "default": '', trim: true},
		title: {type: String, "default": '', trim: true},
		description: {type: String, "default": '', trim: true},
		caption: {type: String, "default": '', trim: true},
		parent: Number,
		mime_type: {type: String, "default": '', trim: true},
	}]
)

postModel = mongo.client.model 'Post', Post

module.exports = postModel

