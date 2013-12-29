mongo = require '../lib/mongo'

Room = new mongo.Schema(
	id: Number
	conferenceId: Number
	name: {type: String, "default": '', trim: true}
	capacity: Number
	locationName: {type: String, "default": '', trim: true}
)

roomModel = mongo.client.model 'Room', Room

module.exports = roomModel

