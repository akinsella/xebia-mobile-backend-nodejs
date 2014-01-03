logger = require 'winston'
_ = require('underscore')._

utils = require '../../lib/utils'
Room = require "../../model/room"
DevoxxEventAwareDataArraySynchronizer = require './DevoxxEventAwareDataArraySynchronizer'

class DevoxxRoomsSynchronizer extends DevoxxEventAwareDataArraySynchronizer

	constructor: (eventId) ->
		logger.info("Instanciating Devoxx Rooms Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("Rooms", eventId)

	path: () ->
		"/schedule/rooms"

	itemTransformer: (rooms) =>
		rooms = _(rooms).sortBy (room) =>
			"#{room.title}".toUpperCase()
		rooms.forEach (room) =>
			room.conferenceId = @eventId
		rooms

	compareFields: () ->
		["name", "capacity", "locationName"]

	query: (room) ->
		id: room.id
		conferenceId: room.conferenceId

	updatedData: (room) ->
		name: room.name
		capacity: room.capacity
		locationName: room.locationName

	itemDescription: (room) ->
		room.name

	createStorableItem: (room) ->
		new Room(room)

	modelClass: () ->
		Room


module.exports = DevoxxRoomsSynchronizer