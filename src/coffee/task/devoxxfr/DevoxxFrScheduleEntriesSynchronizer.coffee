logger = require 'winston'
_ = require('underscore')._
moment = require 'moment'

utils = require '../../lib/utils'
ScheduleEntry = require "../../model/scheduleEntry"
DevoxxFrEventAwareDataArraySynchronizer = require './DevoxxFrEventAwareDataArraySynchronizer'

class DevoxxFrScheduleEntriesSynchronizer extends DevoxxFrEventAwareDataArraySynchronizer

	constructor: (eventId) ->
		logger.info("Instanciating DevoxxFr ScheduleEntries Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("ScheduleEntries", eventId)

	path: () ->
		"/schedule"

	itemTransformer: (scheduleEntries) =>
		scheduleEntries = _(scheduleEntries).sortBy (scheduleEntry) =>
			"#{scheduleEntry.fromTime}"
		scheduleEntries.forEach (scheduleEntry) =>
			scheduleEntry.conferenceId = @eventId
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


module.exports = DevoxxFrScheduleEntriesSynchronizer