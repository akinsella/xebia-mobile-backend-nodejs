logger = require 'winston'
_ = require('underscore')._

utils = require '../../lib/utils'
ExperienceLevel = require "../../model/experienceLevel"
DevoxxFrEventAwareDataArraySynchronizer = require './DevoxxFrEventAwareDataArraySynchronizer'

class DevoxxFrExperienceLevelsSynchronizer extends DevoxxFrEventAwareDataArraySynchronizer

	constructor: (eventId, conferenceName, year) ->
		logger.info("Instanciating #{conferenceName} #{year} ExperienceLevels Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("ExperienceLevels", eventId, conferenceName, year)

	path: () ->
		"/experienceLevels"

	itemTransformer: (experienceLevels) =>
		experienceLevels = _(experienceLevels).sortBy (experienceLevel) =>
			"#{experienceLevel.name}".toUpperCase()
		experienceLevels.forEach (experienceLevel) =>
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


module.exports = DevoxxFrExperienceLevelsSynchronizer