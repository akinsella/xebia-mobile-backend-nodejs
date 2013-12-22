mongo = require '../lib/mongo'

Speaker = new mongo.Schema(
	id: Number
	conferenceId: Number
	lastname: {type: String, "default": '', trim: true}
	bio: {type: String, "default": '', trim: true}
	company: {type: String, "default": '', trim: true}
	imageURI: {type: String, "default": '', trim: true}
	firstname: {type: String, "default": '', trim: true}
	tweethandle: {type: String, "default": '', trim: true}
	talks: [
		{
			title: {type: String, "default": '', trim: true}
			event: {type: String, "default": '', trim: true}
			presentationUri: {type: String, "default": '', trim: true}
			presentationId: Number
		}
	]
)

speakerModel = mongo.client.model 'Speaker', Speaker

module.exports = speakerModel

