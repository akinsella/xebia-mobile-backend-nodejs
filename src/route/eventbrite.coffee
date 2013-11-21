utils = require '../lib/utils'
_ = require('underscore')._
fs = require 'fs'
config = require '../conf/config'

apiKey = process.env["EVENTBRITE_AUTH_KEY"]

# To be refactored
processRequest = (req, res, url, transform) ->

	options = utils.buildOptions req, res, url, 5 * 60, transform
	utils.processRequest options


eventProps = [
	"id", "category", "capacity", "title", "start_date", "end_date",
	"timezone_offset", "tags", "created", "url", "privacy", "status", "description", "description_plain_text",
	"organizer", "venue"
]
organizerProps = [
	"id", "name", "url", "description"
]
venueProps = [
	"id", "name", "city", "region", "country", "country_code", "address", "address_2", "postal_code", "longitude", "latitude"
]

# To be refactored
list = (req, res) ->
	if config.offlineMode
		res.charset = 'UTF-8'
		res.send JSON.parse(fs.readFileSync("#{__dirname}/../data/eventbrite_event.json", "utf-8"))
	else
		processRequest req, res, "https://www.eventbrite.com/json/organizer_list_events?app_key=#{apiKey}&id=1627902102", (data, cb) ->
			events = extractEvents(data)
			cb(undefined, events)


# To be refactored
event = (req, res) ->
		eventId = req.params.id
		processRequest req, res, "https://www.eventbrite.com/json/organizer_list_events?app_key=#{apiKey}&id=1627902102", (data, cb) ->
			events = extractEvents(data)
			event = _(events).find((event) -> String(event.id) == eventId)
			cb(undefined, event)

extractEvents = (data) ->
	_.chain(data.events)
		.pluck("event")
		.sortBy((event) -> event.start_date)
		.filter((event) -> event.status == "Live" || event.status == "Completed")
		.reverse()
		.map(transformEvent)
		.value()

transformEvent = (event) ->
	event.description_plain_text = event.description
	if event.description_plain_text
		event.description_plain_text = event.description_plain_text.replace(/<\/?([a-z][a-z0-9]*)\b[^>]*>?/gi, '')
		event.description_plain_text = event.description_plain_text.replace(/<!--(.*?)-->/g, '')
		event.description_plain_text = event.description_plain_text.replace(/\n\s*\n/g, '\n')

	for key of event
		if !(key in eventProps) then delete event[key]
		for vKey of event.venue
			if !(vKey in venueProps) then delete event.venue[vKey]
		for oKey of event.organizer
			if !(oKey in organizerProps) then delete event.organizer[oKey]
	event

module.exports =
	list : list
	event : event
