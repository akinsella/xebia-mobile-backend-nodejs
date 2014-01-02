logger = require 'winston'
_ = require('underscore')._

utils = require '../../lib/utils'
Track = require "../../model/track"
DevoxxEventAwareDataArraySynchronizer = require './DevoxxEventAwareDataArraySynchronizer'

class DevoxxTracksSynchronizer extends DevoxxEventAwareDataArraySynchronizer

	constructor: (eventId) ->
		logger.info("Instanciating Devoxx Tracks Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("Tracks", eventId)

	path: () ->
		"/tracks"

	itemTransformer: (tracks) =>
		tracks = _(tracks).sortBy (track) ->
			track.name.toUpperCase()
		tracks.forEach (track) ->
			track.conferenceId = @eventId
			track.descriptionPlainText = utils.htmlToPlainText(track.description)
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

	itemTitle: (item) ->
		"#{item.name}"



module.exports = DevoxxTracksSynchronizer