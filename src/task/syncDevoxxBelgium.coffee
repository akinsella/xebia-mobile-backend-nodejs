async = require 'async'
moment = require "moment"
_ = require('underscore')._
request = require "request"

config = require "../conf/config"

utils = require '../lib/utils'
db = require "../db"

ExperienceLevel = require "../model/experienceLevel"
PresentationType = require "../model/presentationType"

eventId = 10

synchronize = () ->
	callback = (err, results) ->
		if err
			console.log "Devoxx Belgium Synchronization ended with error: #{err.message} - Error: #{err}"
		else
			console.log "Devoxx Belgium Synchronization ended with success !"

	if config.feature.stopWatch
		callback = utils.stopWatchCallbak callback

	console.log "Start synchronizing Devoxx Belgium data ..."

	async.parallel [
		processDevoxxExperienceLevels,
		processDevoxxPresentationTypes
	], callback

processDevoxxExperienceLevels = (callback) ->
    console.log "Start synchronizing Devoxx Experience Levels ..."
    request.get {url: "https://cfp.devoxx.com/rest/v1/events/#{eventId}/experiencelevels", json: true}, (error, data, response) ->
	    experienceLevels = _(response).sortBy (experienceLevel) ->
		    experienceLevel.Name.toUpperCase()
	    experienceLevels.forEach (experienceLevel) ->
		    experienceLevel.conferenceId = eventId
	    async.map experienceLevels, synchronizeDevoxxExperienceLevel, (err, results) ->
            console.log "Synchronized #{results.length} Experience Levels"

processDevoxxPresentationTypes = (callback) ->
    console.log "Start synchronizing Devoxx Presentation Types ..."
    request.get {url: "https://cfp.devoxx.com/rest/v1/events/#{eventId}/presentationtypes", json: true}, (error, data, response) ->
	    presentationTypes = _(response).sortBy((presentationType) ->
		    presentationType.name.toUpperCase())
	    presentationTypes.forEach (presentationType) ->
		    presentationType.conferenceId = eventId
	    async.map presentationTypes, synchronizeDevoxxPresentationType, (err, results) ->
            console.log "Synchronized #{results.length} Presentation Types"

synchronizeDevoxxExperienceLevel = (experienceLevel, callback) ->
	query = { name: experienceLevel.name, conferenceId: experienceLevel.conferenceId }
	ExperienceLevel.findOne query, (err, experienceLevelFound) ->
		if err || experienceLevelFound
			callback err, experienceLevelFound?.name
		else
			experienceLevel.name = experienceLevel.Name
			delete experienceLevel.Name
			new ExperienceLevel(experienceLevel).save (err) ->
			callback err, experienceLevel.name
			console.log("New experience level synchronised: #{experienceLevel.name}")

synchronizeDevoxxPresentationType = (presentationType, callback) ->
	query = { id: presentationType.id, conferenceId: presentationType.conferenceId }
	PresentationType.findOne query, (err, presentationTypeFound) ->
		if err
			callback err
		else if presentationTypeFound
			if utils.isNotSame(presentationType, presentationTypeFound, ["name", "description"])
				updatedData = { name: presentationType.name, description: presentationType.description }
				PresentationType.update query, updatedData, (err, numberAffected, raw) ->
					callback err, presentationTypeFound?.id
			else
				callback err, presentationTypeFound.id
		else
			new PresentationType(presentationType).save (err) ->
				console.log("New experience level synchronized: #{presentationType.name}")
				callback err, presentationType.id

module.exports =
	synchronize: synchronize
