logger = require 'winston'
_ = require('underscore')._

utils = require '../../lib/utils'
Track = require "../../model/track"
DevoxxFrEventAwareDataArraySynchronizer = require './DevoxxFrEventAwareDataArraySynchronizer'

class DevoxxFrTracksSynchronizer extends DevoxxFrEventAwareDataArraySynchronizer

	constructor: (eventId) ->
		logger.info("Instanciating DevoxxFr Tracks Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("Tracks", eventId)

	path: () ->
		"/tracks"

	itemTransformer: (tracks) =>
		tracks = _(tracks).sortBy (track) =>
			track.name.toUpperCase()
		tracks.forEach (track) =>
			track.conferenceId = @eventId
		tracks

	compareFields: () ->
		["name", "description", "descriptionPlainText"]

	query: (presentation) ->
		id: presentation.id
		conferenceId: presentation.conferenceId

	updatedData: (track) ->
		name: track.name
		description: track.description
		descriptionPlainText: track.descriptionPlainText

	itemDescription: (track) ->
		track.name

	createStorableItem: (track) ->
		new Track(track)

	modelClass: () ->
		Track


module.exports = DevoxxFrTracksSynchronizer