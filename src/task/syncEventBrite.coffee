utils = require '../lib/utils'
async = require 'async'
_ = require('underscore')._
News = require "../model/news"
db = require "../db"
moment = require "moment"
config = require "../conf/config"
request = require "request"

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

		events = _(response.events)
			.pluck("event")

		events = _(events)
			.sortBy((event) -> event.start_date)

		events = _(events)
			.filter((event) -> event.status == "Live" || event.status == "Completed")

		events = _(events)
			.reverse()

		_(events).each((event) ->
			event
		)

		async.map events, synchronizeEventNews, callback


synchronizeEventNews = (event, callback) ->
	News.findOne { type: 'eventbrite', typeId: event.id }, (err, news) ->
		if err
			callback err
		else if !news

			event.description_plain_text = event.description
			if event.description_plain_text
				event.description_plain_text = event.description_plain_text.replace(/<\/?([a-z][a-z0-9]*)\b[^>]*>?/gi, '')
				event.description_plain_text = event.description_plain_text.replace(/<!--(.*?)-->/g, '')
				event.description_plain_text = event.description_plain_text.replace(/\n\s*\n/g, '\n')


			newsEntry = new News(
				content: event.description_plain_text
				draft: false
				imageUrl: ""
				publicationDate: event.created
				targetUrl: event.url
				title: event.title
				author: event.organizer.name
				type: "eventbrite"
				typeId: event.id
			)

			newsEntry.save (err) ->
				callback err, newsEntry
		else
			callback err, undefined


module.exports =
	synchronize: synchronize
