mongo = require '../lib/mongo'

Presentation = new mongo.Schema(
	id: String
	conferenceId: Number
	summary: {type: String, "default": '', trim: true}
	title: {type: String, "default": '', trim: true}
	track: {type: String, "default": '', trim: true}
	experience: {type: String, "default": '', trim: true}
	language: {type: String, "default": '', trim: true}
	type: {type: String, "default": '', trim: true}
	room: {type: String, "default": '', trim: true}
	fromTime: Date
	toTime: Date
	speakers: [
		{
			id: String
			uri: {type: String, "default": '', trim: true}
			name: {type: String, "default": '', trim: true}
		}
	]
	tags: [
		{
			name: {type: String, "default": '', trim: true}
		}
	]
)

presentationModel = mongo.client.model 'Presentation', Presentation

module.exports = presentationModel

