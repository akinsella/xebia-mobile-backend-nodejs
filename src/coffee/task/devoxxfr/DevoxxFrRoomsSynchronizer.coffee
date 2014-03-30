logger = require 'winston'
_ = require('underscore')._

utils = require '../../lib/utils'
Room = require "../../model/room"
DevoxxFrEventAwareDataArraySynchronizer = require './DevoxxFrEventAwareDataArraySynchronizer'

class DevoxxFrRoomsSynchronizer extends DevoxxFrEventAwareDataArraySynchronizer

	constructor: (eventId) ->
		logger.info("Instanciating DevoxxFr Rooms Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("Rooms", eventId)

	path: () ->
		"/rooms"

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


module.exports = DevoxxFrRoomsSynchronizer