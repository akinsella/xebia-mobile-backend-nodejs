logger = require 'winston'
_ = require('underscore')._

utils = require '../../lib/utils'
Speaker = require "../../model/speaker"
DevoxxBeEventAwareDataArraySynchronizer = require './DevoxxBeEventAwareDataArraySynchronizer'

class DevoxxBeSpeakersSynchronizer extends DevoxxBeEventAwareDataArraySynchronizer

	constructor: (eventId) ->
		logger.info("Instanciating DevoxxBe Speakers Synchronizer with eventId: '#{eventId}'")
		logger.info("eventId: #{eventId}")
		super("Speakers", eventId)

	path: () ->
		"/speakers"

	itemTransformer: (speakers) =>
		speakers = _(speakers).sortBy (speaker) =>
			"#{speaker.firstName} #{speaker.lastName}".toUpperCase()
		speakers.forEach (speaker) =>
			speaker.conferenceId = @eventId
			speaker.imageURL = speaker.imageURI
			delete speaker.imageURI
			speaker.tweetHandle = if speaker.tweethandle then speaker.tweethandle else ""
			delete speaker.tweethandle
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
		new Speaker(speaker)

	modelClass: () ->
		Speaker


module.exports = DevoxxBeSpeakersSynchronizer