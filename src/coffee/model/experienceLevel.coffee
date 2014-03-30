mongo = require '../lib/mongo'

ExperienceLevel = new mongo.Schema(
	name: String
	conferenceId: Number
)

experienceLevelModel = mongo.client.model 'ExperienceLevel', ExperienceLevel

module.exports = experienceLevelModel

