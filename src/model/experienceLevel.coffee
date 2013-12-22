mongo = require '../lib/mongo'

ExperienceLevel = new mongo.Schema(
	name: {type: String, "default": '', trim: true}
	conferenceId: Number
)

experienceLevelModel = mongo.client.model 'ExperienceLevel', ExperienceLevel

module.exports = experienceLevelModel

