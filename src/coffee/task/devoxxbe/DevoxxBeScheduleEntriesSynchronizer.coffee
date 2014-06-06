logger = require 'winston'
_ = require('underscore')._
moment = require 'moment'

utils = require '../../lib/utils'
ScheduleEntry = require "../../model/scheduleEntry"
DevoxxBeEventAwareDataArraySynchronizer = require './DevoxxBeEventAwareDataArraySynchronizer'

class DevoxxBeScheduleEntriesSynchronizer extends DevoxxBeEventAwareDataArraySynchronizer

	constructor: (eventId) ->
		logger.info("Instanciating DevoxxBe ScheduleEntries Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("ScheduleEntries", eventId)

	path: () ->
		"/schedule"

	itemTransformer: (scheduleEntries) =>
		scheduleEntries = _(scheduleEntries).sortBy (scheduleEntry) =>
			"#{scheduleEntry.fromTime}"
		scheduleEntries.forEach (scheduleEntry) =>
			scheduleEntry.conferenceId = @eventId
			scheduleEntry.title = scheduleEntry.title ?= scheduleEntry.code
			scheduleEntry.note = scheduleEntry.note ?= ""
			if scheduleEntry.speakers
				scheduleEntry.speakers = _(scheduleEntry.speakers).unique()
				scheduleEntry.speakers.forEach (speaker) =>
					speaker.id = speaker.speakerId
					delete speaker.speakerId
					speaker.name = speaker.speaker
					delete speaker.speaker
					speaker.uri = speaker.speakerUri
					delete speaker.speakerUri
			else
				scheduleEntry.speakers = []
			delete scheduleEntry.speaker
			delete scheduleEntry.speakerId
			delete scheduleEntry.speakerUri
			if scheduleEntry.presentationId && scheduleEntry.title
				scheduleEntry.presentation =
					id: scheduleEntry.presentationId
					title: scheduleEntry.title ?= ""
					uri: scheduleEntry.presentationUri
			delete scheduleEntry.presentationId
			delete scheduleEntry.presentationUri
			scheduleEntry.fromTime = moment(scheduleEntry.fromTime, "YYYY-MM-DD HH:mm:ss.S")
			scheduleEntry.toTime = moment(scheduleEntry.toTime, "YYYY-MM-DD HH:mm:ss.S")
		scheduleEntries

	compareFields: () ->
		["partnerSlot", "title", "code", "type", "kind", "room", "fromTime", "toTime", "note"]

	query: (scheduleEntry) ->
		id: scheduleEntry.id
		conferenceId: scheduleEntry.conferenceId

	updatedData: (scheduleEntry) ->
		partnerSlot: scheduleEntry.partnerSlot
		title: scheduleEntry.title
		code: scheduleEntry.code
		type: scheduleEntry.type
		kind: scheduleEntry.kind
		room: scheduleEntry.room
		fromTime: scheduleEntry.fromTime
		toTime: scheduleEntry.toTime
		note: scheduleEntry.note

	itemDescription: (scheduleEntry) ->
		scheduleEntry.title

	createStorableItem: (scheduleEntry) ->
		new ScheduleEntry(scheduleEntry)

	modelClass: () ->
		ScheduleEntry


module.exports = DevoxxBeScheduleEntriesSynchronizer