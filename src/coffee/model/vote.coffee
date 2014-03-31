pureautoinc  = require 'mongoose-pureautoinc'

mongo = require '../lib/mongo'

Vote = new mongo.Schema(
	deviceId: String
	conferenceId: Number
	date: {type: Date, required:true, index:true}
	vote: Number
	presentationId: String
)

voteModel = mongo.client.model 'Vote', Vote

Vote.plugin(pureautoinc.plugin, {
	model: 'Vote',
	field: 'id'
});

module.exports = voteModel

