utils = require '../lib/utils'
_ = require('underscore')._
fs = require 'fs'
config = require '../conf/config'
Event = require '../model/event'

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
		Event.find({}).sort("-start_date").limit(50).exec (err, events) ->
			if err
				res.json 500, { message: "Server error: #{err.message}" }
			else if !event
				res.json 404, "Not Found"
			else
				events = events.map (event) ->
					event = event.toObject()
					delete event._id
					delete event.__v
					event
				res.json events


# To be refactored
event = (req, res) ->
	eventId = req.params.id
	Event.findOne { id: eventId }, (err, event) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }

		else if !event
			res.json 404, "Not Found"
		else
			event = event.toObject()
			delete event._id
			delete event.__v
			res.json event


module.exports =
	list : list
	event : event
