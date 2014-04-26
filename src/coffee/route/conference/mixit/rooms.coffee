##################################################################################
# Imports
##################################################################################

logger = require 'winston'
_ = require('underscore')._
async = require 'async'
request = require 'request'
url = require 'url'
moment = require 'moment-timezone'
Q = require 'q'

##################################################################################
# Constants
##################################################################################

eventId = 13
talksURL = "http://www.mix-it.fr/api/talks"
lightningTalksURL = "http://www.mix-it.fr/api/lightningtalks"


##################################################################################
# Schedules
##################################################################################

rooms = (req, res) ->
	Q.spread [
		Q.nfcall(fetchTalks, talksURL)
		Q.nfcall(fetchTalks, lightningTalksURL)
	], (fetchedTalks, fetchedLightningTalks) ->
		for talk in fetchedLightningTalks
			fetchedTalks.push talk

		rooms = _(fetchedTalks)
			.uniq()
			.filter (room) ->
				room != "" && room != undefined
			.map (room) ->
				id: room.toUpperCase().replace(/[\ \-]/g, "_")
				capacity: 0
				conferenceId: eventId
				locationName: ""
				name: room

		res.json rooms
	.fail (err) ->
		logger.info "Error - Message: #{err}"
	.done()


fetchTalks = (talksURL, callback) ->
	request.get { url: talksURL, json: true }, (error, response, fetchedTalks) ->
		if error
			callback(error)
		else
			callback undefined, fetchedTalks.map (talk) ->
				talk.room


module.exports =
	rooms: rooms
