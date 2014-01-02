logger = require 'winston'
async = require 'async'
moment = require "moment"
request = require "request"
_ = require('underscore')._

config = require "../conf/config"
utils = require '../lib/utils'
db = require "../db"
News = require "../model/news"

synchronize = () ->
	callback = (err, news) ->
		if err
			logger.info "EventBrite Synchronization ended with error: #{err.message} - Error: #{err}"
		else
			logger.info "EventBrite Synchronization ended with success ! (#{news.length} events synchronized)"

	if config.feature.stopWatch
		callback = utils.stopWatchCallbak callback

	logger.info "Start synchronizing EventBrite entries ..."

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

			event.descriptionPlainText = event.description
			if event.descriptionPlainText
				event.descriptionPlainText = utils.htmlToPlainText(event.descriptionPlainText)

			newsEntry = new News(
				content: event.descriptionPlainText
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
				callback err, newsEntry.id

		else
			callback err, news.id


module.exports =
	synchronize: synchronize
