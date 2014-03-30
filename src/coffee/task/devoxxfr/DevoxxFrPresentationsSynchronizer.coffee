logger = require 'winston'
_ = require('underscore')._

utils = require '../../lib/utils'
Presentation = require "../../model/presentation"
DevoxxFrEventAwareDataArraySynchronizer = require './DevoxxFrEventAwareDataArraySynchronizer'

class DevoxxFrPresentationsSynchronizer extends DevoxxFrEventAwareDataArraySynchronizer

	constructor: (eventId) ->
		logger.info("Instanciating DevoxxFr Presentation Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("Presentations", eventId)

	path: () ->
		"/presentations"

	itemTransformer: (presentations) =>
		presentations = _(presentations).sortBy (presentation) =>
			"#{presentation.title}".toUpperCase()
		presentations.forEach (presentation) =>
			presentation.conferenceId = @eventId
		presentations

	compareFields: () ->
		["summary", "title", "track", "experience", "language", "type", "room"]

	query: (presentation) ->
		id: presentation.id
		conferenceId: presentation.conferenceId

	updatedData: (presentation) ->
		summary: presentation.summary
		title: presentation.title
		track: presentation.track
		experience: presentation.experience
		language: presentation.language
		type: presentation.type
		room: presentation.room

	itemDescription: (presentation) ->
		presentation.title

	createStorableItem: (presentation) ->
		new Presentation(presentation)

	modelClass: () ->
		Presentation


module.exports = DevoxxFrPresentationsSynchronizer