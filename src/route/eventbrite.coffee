utils = require '../lib/utils'
_ = require('underscore')._
fs = require 'fs'
config = require '../conf/config'
Event = require '../model/event'

# To be refactored
list = (req, res) ->
	if config.offlineMode
		res.charset = 'UTF-8'
		res.send JSON.parse(fs.readFileSync("#{__dirname}/../data/eventbrite_event.json", "utf-8"))
	else
		Event.find({}).sort("-startDate").limit(50).exec (err, events) ->
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
