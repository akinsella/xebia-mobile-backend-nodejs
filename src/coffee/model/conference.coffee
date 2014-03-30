mongo = require '../lib/mongo'

Conference = new mongo.Schema(
	id: Number
	to: {type: String, "default": '', trim: true}
	enabled: {type: Boolean, "default": false, trim: true}
	location: {type: String, "default": '', trim: true}
	description: {type: String, "default": '', trim: true}
	name: {type: String, "default": '', trim: true}
	from: {type: String, "default": '', trim: true}
	iconUrl: {type: String, "default": '', trim: true}
	logoUrl: {type: String, "default": '', trim: true}
	backgroundUrl: {type: String, "default": '', trim: true}
)

conferenceModel = mongo.client.model 'Conference', Conference

module.exports = conferenceModel

