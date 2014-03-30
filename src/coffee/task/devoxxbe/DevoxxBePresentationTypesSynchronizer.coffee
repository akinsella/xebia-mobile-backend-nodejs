logger = require 'winston'
_ = require('underscore')._

utils = require '../../lib/utils'
PresentationType = require "../../model/presentationType"
DevoxxBeEventAwareDataArraySynchronizer = require './DevoxxBeEventAwareDataArraySynchronizer'

class DevoxxBePresentationTypesSynchronizer extends DevoxxBeEventAwareDataArraySynchronizer

	constructor: (eventId) ->
		logger.info("Instanciating DevoxxBe PresentationTypes Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("PresentationTypes", eventId)

	path: () ->
		"/presentationtypes"

	itemTransformer: (presentationTypes) =>
		presentationTypes = _(presentationTypes).sortBy (presentationType) =>
			"#{presentationType.title}".toUpperCase()
		presentationTypes.forEach (presentationType) =>
			presentationType.conferenceId = @eventId
		presentationTypes

	compareFields: () ->
		["name", "description", "descriptionPlainText"]

	query: (presentationType) ->
		id: presentationType.id
		conferenceId: presentationType.conferenceId

	updatedData: (presentationType) ->
		name: presentationType.name
		description: presentationType.description
		descriptionPlainText: utils.htmlToPlainText(presentationType.description)

	itemDescription: (presentationType) ->
		presentationType.name

	createStorableItem: (presentationType) ->
		new PresentationType(presentationType)

	modelClass: () ->
		PresentationType


module.exports = DevoxxBePresentationTypesSynchronizer