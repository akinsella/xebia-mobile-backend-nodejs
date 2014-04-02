pureautoinc  = require 'mongoose-pureautoinc'

mongo = require '../lib/mongo'

Rating = new mongo.Schema(
	deviceId: String
	conferenceId: Number
	date: {type: Date, required:true, index:true}
	rating: Number
	presentationId: String
)

ratingModel = mongo.client.model 'Rating', Rating

Rating.plugin(pureautoinc.plugin, {
	model: 'Rating',
	field: 'id'
});

module.exports = ratingModel

