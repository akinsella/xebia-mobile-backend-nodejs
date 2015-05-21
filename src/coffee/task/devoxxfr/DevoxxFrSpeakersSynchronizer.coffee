logger = require 'winston'
_ = require('underscore')._

utils = require '../../lib/utils'
Speaker = require "../../model/speaker"
DevoxxFrEventAwareDataArraySynchronizer = require './DevoxxFrEventAwareDataArraySynchronizer'

class DevoxxFrSpeakersSynchronizer extends DevoxxFrEventAwareDataArraySynchronizer

	constructor: (eventId, conferenceName, year) ->
		logger.info("Instanciating #{conferenceName} #{year} Speakers Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("Speakers", eventId, conferenceName, year)

	path: () ->
		"/speakers"

	itemTransformer: (speakers) =>
		speakers = _(speakers).sortBy (speaker) =>
			"#{speaker.firstName} #{speaker.lastName}".toUpperCase()
		speakers.forEach (speaker) =>
			speaker.conferenceId = @eventId
		speakers

	compareFields: () ->
		["lastName", "bio", "company", "imageURI", "firstName", "tweethandle"]

	query: (speaker) ->
		id: speaker.id
		conferenceId: speaker.conferenceId

	updatedData: (speaker) ->
		lastName: speaker.lastName
		bio: speaker.bio
		company: speaker.company
		imageURL: speaker.imageURL
		firstName: speaker.firstName
		tweetHandle: speaker.tweetHandle

	itemDescription: (speaker) ->
		"#{speaker.firstName} #{speaker.lastName}"

	createStorableItem: (speaker) ->
		logger.info("Speaker: #{speaker}")
		new Speaker(speaker)

	modelClass: () ->
		Speaker


module.exports = DevoxxFrSpeakersSynchronizer