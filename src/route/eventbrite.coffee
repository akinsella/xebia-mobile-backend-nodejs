utils = require '../lib/utils'
_ = require('underscore')._
fs = require 'fs'
config = require '../conf/config'

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
		apiKey = process.env["EVENTBRITE_AUTH_KEY"]
		processRequest req, res, "https://www.eventbrite.com/json/organizer_list_events?app_key=#{apiKey}&id=1627902102", (data, cb) ->
			data = _(data.events)
				.pluck("event")

			data = _(data)
				.sortBy((event) -> event.start_date)

			data = _(data)
				.filter((event) -> event.status == "Live" || event.status == "Completed")

			data = _(data)
				.reverse()
			_(data).each((event) ->
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
			)
			cb(undefined, data)

module.exports =
	list : list
