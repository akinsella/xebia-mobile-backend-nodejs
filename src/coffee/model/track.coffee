mongo = require '../lib/mongo'

Track = new mongo.Schema(
	id: String
	conferenceId: Number
	name: {type: String, "default": '', trim: true}
	description: {type: String, "default": '', trim: true}
	descriptionPlainText: {type: String, "default": '', trim: true}
)

trackModel = mongo.client.model 'Track', Track

module.exports = trackModel

