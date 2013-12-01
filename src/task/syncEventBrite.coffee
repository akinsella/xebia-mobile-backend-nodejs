utils = require '../lib/utils'
async = require 'async'
_ = require('underscore')._
Event = require "../model/event"
db = require "../db"
moment = require "moment"
config = require "../conf/config"
request = require "request"
apns = require "../lib/apns"


eventProps = [
	"id", "category", "capacity", "title", "startDate", "endDate",
	"timezoneOffset", "tags", "created", "url", "privacy", "status", "description", "descriptionPlainText",
	"organizer", "venue"
]
organizerProps = [
	"id", "name", "url", "description"
]
venueProps = [
	"id", "name", "city", "region", "country", "countryCode", "address", "address2", "postalCode", "longitude", "latitude"
]

synchronize = () ->
	callback = (err, news) ->
		if err
			console.log "EventBrite Synchronization ended with error: #{err.message} - Error: #{err}"
		else
			console.log "EventBrite Synchronization ended with success ! (#{news.length} events synchronized)"

	if config.feature.stopWatch
		callback = utils.stopWatchCallbak callback

	console.log "Start synchronizing EventBrite entries ..."

	processEventBriteEntries(callback)

processEventBriteEntries = (callback) ->

	apiKey = process.env["EVENTBRITE_AUTH_KEY"]
	"https://www.eventbrite.com/json/organizer_list_events?app_key=#{apiKey}&id=1627902102"

	request.get {url: "https://www.eventbrite.com/json/organizer_list_events?app_key=#{apiKey}&id=1627902102", json: true}, (error, data, response) ->

		events = extractEvents(response)
		async.map events, synchronizeEvent, callback


synchronizeEvent = (event, callback) ->
	Event.findOne { id: event.id }, (err, foundEvent) ->
		if err
			callback err
		else if !foundEvent

			eventEntry = new Event(event)

			eventEntry.save (err) ->
				callback err, eventEntry.id
				apns.pushToAll "New event with id: #{eventEntry.id}" , () ->
					console.log "Pushed notification for new event wth id: #{eventEntry.id}"

		else
			callback err, foundEvent.id


extractEvents = (data) ->
	_.chain(data.events)
		.pluck("event")
		.sortBy((event) -> event.start_date)
		.filter((event) -> event.status == "Live" || event.status == "Completed")
		.reverse()
		.map(transformEvent)
		.value()

transformEvent = (event) ->
	event.descriptionPlainText = event.description
	if event.descriptionPlainText
		event.descriptionPlainText = event.descriptionPlainText.replace(/<\/?([a-z][a-z0-9]*)\b[^>]*>?/gi, '')
		event.descriptionPlainText = event.descriptionPlainText.replace(/<!--(.*?)-->/g, '')
		event.descriptionPlainText = event.descriptionPlainText.replace(/\n\s*\n/g, '\n')

	event.startDate = event.start_date
	delete event.start_date
	event.endDate = event.end_date
	delete event.end_date
	event.timezoneOffset = event.timezone_offset
	delete event.timezone_offset

	event.venue.countryCode = event.venue.country_code
	delete event.venue.country_code
	event.venue.address2 = event.venue.address_2
	delete event.venue.address_2
	event.venue.postalCode = event.venue.postal_code
	delete event.venue.postal_code

	for key of event
		if !(key in eventProps) then delete event[key]
		for vKey of event.venue
			if !(vKey in venueProps) then delete event.venue[vKey]
		for oKey of event.organizer
			if !(oKey in organizerProps) then delete event.organizer[oKey]
	event

module.exports =
	synchronize: synchronize
