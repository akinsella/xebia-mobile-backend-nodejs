mongo = require '../lib/mongo'

Tag = new mongo.Schema(
	id: Number,
	title: {type: String, "default": '', trim: true},
	slug: {type: String, "default": '', trim: true},
	description: {type: String, "default": '', trim: true},
	postCount: Number
)

tagModel = mongo.client.model 'Tag', Tag

module.exports = tagModel

