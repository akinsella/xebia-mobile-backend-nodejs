utils = require '../lib/utils'
_ = require('underscore')._

# To be refactored
processRequest = (req, res, url, transform) ->

	options = utils.buildOptions req, res, url, 5 * 60, transform
	utils.processRequest options

	return

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
	apiKey = process.env["EVENTBRITE_AUTH_KEY"]
	processRequest req, res, "https://www.eventbrite.com/json/organizer_list_events?app_key=#{apiKey}&id=1627902102", (data) ->
		data = _(data.events).pluck("event").filter((event) -> event.status == "Live")
		_(data).each((event) ->
			event.description_plain_text = if event.description then event.description.replace(/<\/?([a-z][a-z0-9]*)\b[^>]*>?/gi, '').replace(/<!--(.*?)-->/, '') else event.description
			for key of event
				if !(key in eventProps) then delete event[key]
				for vKey of event.venue
					if !(vKey in venueProps) then delete event.venue[vKey]
				for oKey of event.organizer
					if !(oKey in organizerProps) then delete event.organizer[oKey]
			event
		)
		data

module.exports =
	list : list
