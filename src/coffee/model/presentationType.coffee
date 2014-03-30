mongo = require '../lib/mongo'

PresentationType = new mongo.Schema(
	id: String
	conferenceId: Number
	name: {type: String, "default": '', trim: true}
	description: {type: String, "default": '', trim: true}
	descriptionPlainText: {type: String, "default": '', trim: true}
)

presentationTypeModel = mongo.client.model 'PresentationType', PresentationType

module.exports = presentationTypeModel

