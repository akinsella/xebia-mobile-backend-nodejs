mongo = require '../lib/mongo'

Event = new mongo.Schema(
	id: Number,
	category: {type: String, "default": '', trim: true},
	tags: {type: String, "default": '', trim: true},
	capacity: Number,
	title: {type: String, "default": '', trim: true},
	start_date: {type: String, "default": '', trim: true},
	end_date: {type: String, "default": '', trim: true},
	timezone_offset: {type: String, "default": '', trim: true},
	url: {type: String, "default": '', trim: true}
	privacy: {type: String, "default": '', trim: true}
	status: {type: String, "default": '', trim: true},
	description: {type: String, "default": '', trim: true},
	description_plain_text: {type: String, "default": '', trim: true},
	organizer:{
		id: Number,
		name: {type: String, "default": '', trim: true},
		description: {type: String, "default": '', trim: true},
		url: {type: String, "default": '', trim: true}
	},
	venue:{
		id: Number,
		city: {type: String, "default": '', trim: true},
		name: {type: String, "default": '', trim: true},
		country: {type: String, "default": '', trim: true},
		region: {type: String, "default": '', trim: true},
		postal_code: {type: String, "default": '', trim: true},
		address_2: {type: String, "default": '', trim: true},
		address: {type: String, "default": '', trim: true},
		country_code: {type: String, "default": '', trim: true},
		latitude: Number,
		longitude: Number
	}
)

eventModel = mongo.client.model 'Event', Event

module.exports = eventModel

