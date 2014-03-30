logger = require 'winston'
_ = require('underscore')._

utils = require '../lib/utils'
Conference = require "../model/conference"
FileSystemDataSynchronizer = require './FileSystemDataSynchronizer'

class ConferencesSynchronizer extends FileSystemDataSynchronizer

	constructor: () ->
		logger.info("Instanciating Conferences Synchronizer")
		super("Conferences")

	path: () ->
		"#{__dirname}/../data/conferences.json"

	itemTransformer: (conferences) =>
		conferences = _(conferences).sortBy (conference) =>
			"#{conference.name}".toUpperCase()
		conferences

	compareFields: () ->
		["name", "capacity", "locationName"]

	query: (conference) ->
		id: conference.id

	updatedData: (conference) ->
		name: conference.name
		capacity: conference.capacity
		from: conference.from
		to: conference.to
		enabled: conference.enabled
		location: conference.location
		description: conference.description
		iconUrl: conference.iconUrl
		logoUrl: conference.logoUrl
		backgroundUrl: conference.backgroundUrl

	itemDescription: (conference) ->
		conference.name

	createStorableItem: (conference) ->
		new Conference(conference)

	modelClass: () ->
		Conference


module.exports = ConferencesSynchronizer