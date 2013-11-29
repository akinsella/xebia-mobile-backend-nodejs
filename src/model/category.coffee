mongo = require '../lib/mongo'

Category = new mongo.Schema(
	id: Number,
	parent: Number,
	title: {type: String, "default": '', trim: true},
	slug: {type: String, "default": '', trim: true},
	description: {type: String, "default": '', trim: true},
	post_count: Number
)

categoryModel = mongo.client.model 'Category', Category

module.exports = categoryModel

