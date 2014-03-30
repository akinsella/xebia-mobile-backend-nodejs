logger = require 'winston'
_ = require('underscore')._

utils = require '../../lib/utils'
ExperienceLevel = require "../../model/experienceLevel"
DevoxxBeEventAwareDataArraySynchronizer = require './DevoxxBeEventAwareDataArraySynchronizer'

class DevoxxBeExperienceLevelsSynchronizer extends DevoxxBeEventAwareDataArraySynchronizer

	constructor: (eventId) ->
		logger.info("Instanciating DevoxxBe ExperienceLevels Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("ExperienceLevels", eventId)

	path: () ->
		"/experiencelevels"

	itemTransformer: (experienceLevels) =>
		experienceLevels = _(experienceLevels).sortBy (experienceLevel) =>
			experienceLevel.Name.toUpperCase()
		experienceLevels.forEach (experienceLevel) =>
			experienceLevel.name = experienceLevel.Name
			delete experienceLevel.Name
			experienceLevel.conferenceId = @eventId
		experienceLevels

	compareFields: () ->
		[]

	query: (experienceLevel) ->
		name: experienceLevel.name
		conferenceId: experienceLevel.conferenceId

	updatedData: (experienceLevel) ->
		{}

	itemDescription: (experienceLevel) ->
		experienceLevel.name

	createStorableItem: (experienceLevel) ->
		new ExperienceLevel(experienceLevel)

	modelClass: () ->
		ExperienceLevel


module.exports = DevoxxBeExperienceLevelsSynchronizer