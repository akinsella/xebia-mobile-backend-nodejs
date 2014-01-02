logger = require 'winston'
_ = require('underscore')._

utils = require '../../lib/utils'
Presentation = require "../../model/presentation"
DevoxxEventAwareDataArraySynchronizer = require './DevoxxEventAwareDataArraySynchronizer'

class DevoxxPresentationsSynchronizer extends DevoxxEventAwareDataArraySynchronizer

	constructor: (eventId) ->
		logger.info("Instanciating Devoxx Presentation Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("Presentations", eventId)

	path: () ->
		"/presentations"

	itemTransformer: (presentations) =>
		presentations = _(presentations).sortBy (presentation) ->
			"#{presentation.title}".toUpperCase()
		presentations.forEach (presentation) =>
			if !presentation.room
				presentation.room = ""
			presentation.conferenceId = @eventId
			if presentation.speakers
				presentation.speakers.forEach (speaker) ->
					speaker.id = speaker.speakerId
					delete speaker.speakerId
					speaker.name = speaker.speaker
					delete speaker.speaker
					speaker.uri = speaker.speakerUri
					delete speaker.speakerUri
			else
				presentation.speakers = []
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

	itemTitle: (item) ->
		"#{item.title}"


module.exports = DevoxxPresentationsSynchronizer