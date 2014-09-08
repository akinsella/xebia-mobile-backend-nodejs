mongo = require '../lib/mongo'

DetailedPost = new mongo.Schema(
	id: Number,
	type: {type: String, "default": '', trim: true},
	slug: {type: String, "default": '', trim: true},
	url: {type: String, "default": '', trim: true},
	status: {type: String, "default": '', trim: true},
	title: {type: String, "default": '', trim: true},
	titlePlain: {type: String, "default": '', trim: true},
	content: {type: String, "default": '', trim: true},
	structuredContent: [{
		attributes: [{
			key: {type: String, "default": '', trim: true},
			value: {type: String, "default": '', trim: true}
		}],
		type: {type: String, "default": '', trim: true},
		text: String
	}],
	excerpt: {type: String, "default": '', trim: true},
	date: {type: String, "default": '', trim: true},
	modified: {type: String, "default": '', trim: true},
	commentCount: Number,
	commentStatus: {type: String, "default": '', trim: true},
	categories: [{
		id: Number,
		parent: Number,
		title: {type: String, "default": '', trim: true},
		slug: {type: String, "default": '', trim: true},
		description: {type: String, "default": '', trim: true},
		postCount: Number
	}],
	tags: [{
		id: Number,
		title: {type: String, "default": '', trim: true},
		slug: {type: String, "default": '', trim: true},
		description: {type: String, "default": '', trim: true},
		postCount: Number
	}],
	authors:[{
		id: Number,
		slug: {type: String, "default": '', trim: true},
		name: {type: String, "default": '', trim: true},
		firstName: {type: String, "default": '', trim: true},
		lastName: {type: String, "default": '', trim: true},
		nickname: {type: String, "default": '', trim: true},
		url: {type: String, "default": '', trim: true},
		description: {type: String, "default": '', trim: true}
	}],
	coAuthors:[{
		id: Number,
		slug: {type: String, "default": '', trim: true},
		name: {type: String, "default": '', trim: true},
		firstName: {type: String, "default": '', trim: true},
		lastName: {type: String, "default": '', trim: true},
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
		mimeType: {type: String, "default": '', trim: true},
	}]
)

detailedPostModel = mongo.client.model 'DetailedPost', DetailedPost

module.exports = detailedPostModel

