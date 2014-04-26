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

presentationTypes = (req, res) ->
	Q.spread [
		Q.nfcall(fetchTalks, talksURL)
#		Q.nfcall(fetchTalks, lightningTalksURL)
	], (fetchedTalks, fetchedLightningTalks) ->
		for talk in fetchedLightningTalks
			fetchedTalks.push talk

		presentationTypes = _(fetchedTalks)
			.uniq()
			.filter (presentationType) ->
				presentationType != "" && presentationType != undefined
			.map (presentationType) ->
				id: presentationType.toUpperCase().replace(/[\ \-]/g, "_")
				conferenceId: eventId
				descriptionPlainText: ""
				description: ""
				name: presentationType

		res.json presentationTypes
	.fail (err) ->
		logger.info "Error - Message: #{err}"
	.done()


fetchTalks = (talksURL, callback) ->
	request.get { url: talksURL, json: true }, (error, response, fetchedTalks) ->
		if error
			callback(error)
		else
			callback undefined, fetchedTalks.map (talk) ->
				talk.format


module.exports =
	presentationTypes: presentationTypes
