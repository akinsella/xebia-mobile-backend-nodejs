mongo = require '../lib/mongo'

Author = new mongo.Schema(
	id: Number,
	slug: {type: String, "default": '', trim: true},
	name: {type: String, "default": '', trim: true},
	firstName: {type: String, "default": '', trim: true},
	lastName: {type: String, "default": '', trim: true},
	nickname: {type: String, "default": '', trim: true},
	url: {type: String, "default": '', trim: true},
	description: {type: String, "default": '', trim: true}
)

authorModel = mongo.client.model 'Author', Author

module.exports = authorModel

