logger = require 'winston'
_ = require('underscore')._

utils = require '../../lib/utils'
PresentationType = require "../../model/presentationType"
DevoxxFrEventAwareDataArraySynchronizer = require './DevoxxFrEventAwareDataArraySynchronizer'

class DevoxxFrPresentationTypesSynchronizer extends DevoxxFrEventAwareDataArraySynchronizer

	constructor: (eventId, conferenceName, year) ->
		logger.info("Instanciating #{conferenceName} #{year} PresentationTypes Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("PresentationTypes", eventId, conferenceName, year)

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
		descriptionPlainText: presentationType.descriptionPlainText

	itemDescription: (presentationType) ->
		presentationType.name

	createStorableItem: (presentationType) ->
		new PresentationType(presentationType)

	modelClass: () ->
		PresentationType


module.exports = DevoxxFrPresentationTypesSynchronizer