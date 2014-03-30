mongo = require '../lib/mongo'

ScheduleEntry = new mongo.Schema(
	id: String
	conferenceId: Number
	title: {type: String, "default": '', trim: true}
	fromTime: {type: Date, required:true, index:true}
	toTime: {type: Date, required:true, index:true}
	code: {type: String, "default": '', trim: true}
	type: {type: String, "default": '', trim: true}
	kind: {type: String, "default": '', trim: true}
	track: {type: String, "default": '', trim: true}
	room: {type: String, "default": '', trim: true}
	note: {type: String, "default": '', trim: true}
	partnerSlot: {type: Boolean, "default": false}
	speakers: [{
		id: String
		name: {type: String, "default": '', trim: true}
		uri: {type: String, "default": '', trim: true}
	}]
	presentation: {
		id: String
		title: {type: String, "default": '', trim: true}
		uri: {type: String, "default": '', trim: true}
	}
)

scheduleEntryModel = mongo.client.model 'ScheduleEntry', ScheduleEntry

module.exports = scheduleEntryModel

