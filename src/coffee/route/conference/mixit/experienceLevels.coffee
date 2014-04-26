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

experienceLevels = (req, res) ->
	Q.spread [
		Q.nfcall(fetchTalks, talksURL)
	], (fetchedTalks) ->
		experienceLevels = _(fetchedTalks)
		.uniq()
		.filter (experienceLevel) ->
			experienceLevel != "" && experienceLevel != undefined
		.map (experienceLevel) ->
			id: experienceLevel.toUpperCase().replace(/[\ \-]/g, "_")
			conferenceId: eventId
			descriptionPlainText: ""
			description: ""
			name: experienceLevel

		res.json experienceLevels
	.fail (err) ->
		logger.info "Error - Message: #{err}"
	.done()


fetchTalks = (talksURL, callback) ->
	request.get { url: talksURL, json: true }, (error, response, fetchedTalks) ->
		if error
			callback(error)
		else
			callback undefined, fetchedTalks.map (talk) ->
				talk.level


module.exports =
	experienceLevels: experienceLevels
