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

tracks = (req, res) ->
	Q.spread [
		Q.nfcall(fetchTalks, talksURL)
	], (fetchedTalks) ->
		tracks = _(fetchedTalks)
			.uniq()
			.filter (track) ->
				track != "" && track != undefined
			.map (track) ->
				id: track.toUpperCase().replace(/[\ \-]/g, "_")
				conferenceId: eventId
				descriptionPlainText: ""
				description: ""
				name: track

		res.json tracks
	.fail (err) ->
		logger.info "Error - Message: #{err}"
	.done()


fetchTalks = (talksURL, callback) ->
	request.get { url: talksURL, json: true }, (error, response, fetchedTalks) ->
		if error
			callback(error)
		else
			callback undefined, fetchedTalks.map (talk) ->
				talk.track ?= "Mix-IT"


module.exports =
	tracks: tracks
