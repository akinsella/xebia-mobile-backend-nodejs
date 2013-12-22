async = require 'async'
moment = require "moment"
_ = require('underscore')._
request = require "request"

config = require "../conf/config"

utils = require '../lib/utils'
db = require "../db"

ExperienceLevel = require "../model/experienceLevel"
PresentationType = require "../model/presentationType"
Track = require "../model/track"
Speaker = require "../model/speaker"
Presentation = require "../model/presentation"

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
		processDevoxxPresentationTypes,
		processDevoxxTracks,
		processDevoxxSpeakers,
		processDevoxxPresentations
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
		presentationTypes = _(response).sortBy (presentationType) ->
			presentationType.name.toUpperCase()
		presentationTypes.forEach (presentationType) ->
			presentationType.conferenceId = eventId
			presentationType.descriptionPlainText = utils.htmlToPlainText(presentationType.description)
		async.map presentationTypes, synchronizeDevoxxPresentationType, (err, results) ->
			console.log "Synchronized #{results.length} Presentation Types"

processDevoxxTracks = (callback) ->
	console.log "Start synchronizing Devoxx Tracks..."
	request.get {url: "https://cfp.devoxx.com/rest/v1/events/#{eventId}/tracks", json: true}, (error, data, response) ->
		tracks = _(response).sortBy (track) ->
			track.name.toUpperCase()
		tracks.forEach (track) ->
			track.conferenceId = eventId
			track.descriptionPlainText = utils.htmlToPlainText(track.description)
		async.map tracks, synchronizeDevoxxTrack, (err, results) ->
			console.log "Synchronized #{results.length} Tracks"

processDevoxxSpeakers = (callback) ->
	console.log "Start synchronizing Devoxx Speakers ..."
	request.get {url: "https://cfp.devoxx.com/rest/v1/events/#{eventId}/speakers", json: true}, (error, data, response) ->
		speakers = _(response).sortBy (speaker) ->
			"#{speaker.firstName} #{speaker.lastName}".toUpperCase()
		speakers.forEach (speaker) ->
			speaker.conferenceId = eventId
			speaker.firstName = speaker.firstname
			delete speaker.firstname
			speaker.lastName = speaker.lastname
			delete speaker.lastname
			speaker.tweetHandle = speaker.tweethandle
			delete speaker.tweethandle
		async.map speakers, synchronizeDevoxxSpeaker, (err, results) ->
			console.log "Synchronized #{results.length} Speakers"

processDevoxxPresentations = (callback) ->
	console.log "Start synchronizing Devoxx Presentations ..."
	request.get {url: "https://cfp.devoxx.com/rest/v1/events/#{eventId}/presentations", json: true}, (error, data, response) ->
		presentations = _(response).sortBy (presentation) ->
			"#{presentation.title}".toUpperCase()
		presentations.forEach (presentation) ->
			presentation.conferenceId = eventId
		async.map presentations, synchronizeDevoxxPresentation, (err, results) ->
			console.log "Synchronized #{results.length} Presentations"

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
			if utils.isNotSame(presentationType, presentationTypeFound, ["name", "description", "descriptionPlainText"])
				updatedData =
					name: presentationType.name
					description: presentationType.description
					descriptionPlainText: presentationType.descriptionPlainText
				PresentationType.update query, updatedData, (err, numberAffected, raw) ->
					callback err, presentationTypeFound?.id
			else
				callback err, presentationTypeFound.id
		else
			new PresentationType(presentationType).save (err) ->
				console.log("New experience level synchronized: #{presentationType.name}")
				callback err, presentationType.id

synchronizeDevoxxTrack = (track, callback) ->
	query = { id: track.id, conferenceId: track.conferenceId }
	Track.findOne query, (err, trackFound) ->
		if err
			callback err
		else if trackFound
			if utils.isNotSame(track, trackFound, ["name", "description", "descriptionPlainText"])
				updatedData =
					name: track.name
					description: track.description
					descriptionPlainText: track.descriptionPlainText
				Track.update query, updatedData, (err, numberAffected, raw) ->
					callback err, trackFound?.id
			else
				callback err, trackFound.id
		else
			new Track(track).save (err) ->
				console.log("New experience level synchronized: #{track.name}")
				callback err, track.id

synchronizeDevoxxSpeaker = (speaker, callback) ->
	query = { id: speaker.id, conferenceId: speaker.conferenceId }
	Speaker.findOne query, (err, speakerFound) ->
		if err
			callback err
		else if speakerFound
			if utils.isNotSame(speaker, speakerFound, ["lastName", "bio", "company", "imageURI", "firstName", "tweethandle"])
				updatedData =
					lastName: speaker.lastName
					bio: speaker.bio
					company: speaker.company
					imageURI: speaker.imageURI
					firstName: speaker.firstName
					tweetHandle: speaker.tweetHandle
				Speaker.update query, updatedData, (err, numberAffected, raw) ->
					callback err, speakerFound?.id
			else
				callback err, speakerFound.id
		else
			new Speaker(speaker).save (err) ->
				console.log("New speaker synchronized: #{speaker.firstName} #{speaker.lastName}")
				callback err, speaker.id

synchronizeDevoxxPresentation = (presentation, callback) ->
	query = { id: presentation.id, conferenceId: presentation.conferenceId }
	Presentation.findOne query, (err, presentationFound) ->
		if err
			callback err
		else if presentationFound
			if utils.isNotSame(presentation, presentationFound, ["summary", "title", "track", "experience", "language", "type", "room"])
				updatedData =
					summary: presentation.summary
					title: presentation.title
					track: presentation.track
					experience: presentation.experience
					language: presentation.language
					type: presentation.type
					room: presentation.room
				Presentation.update query, updatedData, (err, numberAffected, raw) ->
					callback err, presentationFound?.id
			else
				callback err, presentationFound.id
		else
			new Presentation(presentation).save (err) ->
				console.log("New presentation synchronized: #{presentation.title}")
				callback err, presentation.id

module.exports =
	synchronize: synchronize
