mongo = require '../lib/mongo'

Speaker = new mongo.Schema(
	id: String
	conferenceId: Number
	firstName: {type: String, "default": '', trim: true}
	lastName: {type: String, "default": '', trim: true}
	bio: {type: String, "default": '', trim: true}
	company: {type: String, "default": '', trim: true}
	imageURL: {type: String, "default": '', trim: true}
	tweetHandle: {type: String, "default": '', trim: true}
	blog: {type: String, "default": '', trim: true}
	lang: {type: String, "default": '', trim: true}
	talks: [
		{
			title: {type: String, "default": '', trim: true}
			event: {type: String, "default": '', trim: true}
			track: {type: String, "default": '', trim: true}
			presentationUri: {type: String, "default": '', trim: true}  # Deprecated
			presentationId: String
		}
	]
)

speakerModel = mongo.client.model 'Speaker', Speaker

module.exports = speakerModel

