async = require 'async'
moment = require "moment"
request = require "request"
_ = require('underscore')._

config = require "../conf/config"
utils = require '../lib/utils'
db = require "../db"

ExperienceLevel = require "../model/experienceLevel"
PresentationType = require "../model/presentationType"
Track = require "../model/track"
Speaker = require "../model/speaker"
Presentation = require "../model/presentation"
Room = require "../model/room"
ScheduleEntry = require "../model/scheduleEntry"

eventId = 10
baseUrl = "http://dev.cfp.devoxx.com:3000"

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
		processDevoxxPresentations,
		processDevoxxRooms,
		processDevoxxSchedule
	], callback

processDevoxxExperienceLevels = (callback) ->
    console.log "Start synchronizing Devoxx Experience Levels ..."
    request.get {url: "#{baseUrl}/rest/v1/events/#{eventId}/experiencelevels", json: true}, (error, data, response) ->
	    experienceLevels = _(response).sortBy (experienceLevel) ->
		    experienceLevel.Name.toUpperCase()
	    experienceLevels.forEach (experienceLevel) ->
		    experienceLevel.conferenceId = eventId
	    async.map experienceLevels, synchronizeDevoxxExperienceLevel, (err, results) ->
            console.log "Synchronized #{results.length} Experience Levels"

processDevoxxPresentationTypes = (callback) ->
	console.log "Start synchronizing Devoxx Presentation Types ..."
	request.get {url: "#{baseUrl}/rest/v1/events/#{eventId}/presentationtypes", json: true}, (error, data, response) ->
		presentationTypes = _(response).sortBy (presentationType) ->
			presentationType.name.toUpperCase()
		presentationTypes.forEach (presentationType) ->
			presentationType.conferenceId = eventId
			presentationType.descriptionPlainText = utils.htmlToPlainText(presentationType.description)
		async.map presentationTypes, synchronizeDevoxxPresentationType, (err, results) ->
			console.log "Synchronized #{results.length} Presentation Types"

processDevoxxTracks = (callback) ->
	console.log "Start synchronizing Devoxx Tracks..."
	request.get {url: "#{baseUrl}/rest/v1/events/#{eventId}/tracks", json: true}, (error, data, response) ->
		tracks = _(response).sortBy (track) ->
			track.name.toUpperCase()
		tracks.forEach (track) ->
			track.conferenceId = eventId
			track.descriptionPlainText = utils.htmlToPlainText(track.description)
		async.map tracks, synchronizeDevoxxTrack, (err, results) ->
			console.log "Synchronized #{results.length} Tracks"

processDevoxxSpeakers = (callback) ->
	console.log "Start synchronizing Devoxx Speakers ..."
	request.get {url: "#{baseUrl}/rest/v1/events/#{eventId}/speakers", json: true}, (error, data, response) ->
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
	request.get {url: "#{baseUrl}/rest/v1/events/#{eventId}/presentations", json: true}, (error, data, response) ->
		presentations = _(response).sortBy (presentation) ->
			"#{presentation.title}".toUpperCase()
		presentations.forEach (presentation) ->
			presentation.conferenceId = eventId
			if presentation.speakers
				presentation.speakers.forEach (speaker) ->
					speaker.id = speaker.speakerId
					delete speaker.speakerId
					speaker.name = speaker.speaker
					delete speaker.speaker
					speaker.uri = speaker.speakerUri
					delete speaker.speakerUri
			else
				presentation.speakers = []
		async.map presentations, synchronizeDevoxxPresentation, (err, results) ->
			console.log "Synchronized #{results.length} Presentations"

processDevoxxRooms = (callback) ->
	console.log "Start synchronizing Devoxx Rooms ..."
	request.get {url: "#{baseUrl}/rest/v1/events/#{eventId}/schedule/rooms", json: true}, (error, data, response) ->
		rooms = _(response).sortBy (room) ->
			"#{room.title}".toUpperCase()
		rooms.forEach (room) ->
			room.conferenceId = eventId
		async.map rooms, synchronizeDevoxxRoom, (err, results) ->
			console.log "Synchronized #{results.length} Rooms"

processDevoxxSchedule = (callback) ->
	console.log "Start synchronizing Devoxx Schedule ..."
	request.get {url: "#{baseUrl}/rest/v1/events/#{eventId}/schedule", json: true}, (error, data, response) ->
		scheduleEntries = _(response).sortBy (scheduleEntry) ->
			"#{scheduleEntry.fromTime}"
		scheduleEntries.forEach (scheduleEntry) ->
			scheduleEntry.conferenceId = eventId
			if scheduleEntry.speakers
				scheduleEntry.speakers = _(scheduleEntry.speakers).unique()
				scheduleEntry.speakers.forEach (speaker) ->
					speaker.id = speaker.speakerId
					delete speaker.speakerId
					speaker.name = speaker.speaker
					delete speaker.speaker
					speaker.uri = speaker.speakerUri
					delete speaker.speakerUri
			else
				scheduleEntry.speakers = []
			delete scheduleEntry.speaker
			delete scheduleEntry.speakerId
			delete scheduleEntry.speakerUri
			if scheduleEntry.presentationId && scheduleEntry.title
				scheduleEntry.presentation =
					id: scheduleEntry.presentationId
					title: scheduleEntry.title
					uri: scheduleEntry.presentationUri
			delete scheduleEntry.presentationId
			delete scheduleEntry.presentationUri
			scheduleEntry.fromTime = moment(scheduleEntry.fromTime, "YYYY-MM-DD HH:mm:ss.Z")
			scheduleEntry.toTime = moment(scheduleEntry.toTime, "YYYY-MM-DD HH:mm:ss.Z")

		async.map scheduleEntries, synchronizeDevoxxScheduleEntry, (err, results) ->
			console.log "Synchronized #{results.length} Schedule Entries"

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
			console.log("New Experience Level synchronised: #{experienceLevel.name}")

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
				console.log("New Presentation Type synchronized: #{presentationType.name}")
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
				console.log("New Track synchronized: #{track.name}")
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
				console.log("New Speaker synchronized: #{speaker.firstName} #{speaker.lastName}")
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
				console.log("New Presentation synchronized: #{presentation.title}")
				callback err, presentation.id

synchronizeDevoxxRoom = (room, callback) ->
	query = { id: room.id, conferenceId: room.conferenceId }
	Room.findOne query, (err, roomFound) ->
		if err
			callback err
		else if roomFound
			if utils.isNotSame(room, roomFound, ["name", "capacity", "locationName"])
				updatedData =
					name: room.name
					capacity: room.capacity
					locationName: room.locationName
				Room.update query, updatedData, (err, numberAffected, raw) ->
					callback err, roomFound?.id
			else
				callback err, roomFound.id
		else
			new Room(room).save (err) ->
				console.log("New Room synchronized: #{room.name}")
				callback err, room.id

synchronizeDevoxxScheduleEntry = (scheduleEntry, callback) ->
	query = { id: scheduleEntry.id, conferenceId: scheduleEntry.conferenceId }
	ScheduleEntry.findOne query, (err, scheduleEntryFound) ->
		if err
			callback err
		else if scheduleEntryFound
			if utils.isNotSame(scheduleEntry, scheduleEntryFound, ["partnerSlot", "title", "code", "type", "kind", "room", "fromTime", "toTime", "note"])
				updatedData =
					partnerSlot: scheduleEntry.partnerSlot
					title: scheduleEntry.title
					code: scheduleEntry.code
					type: scheduleEntry.type
					kind: scheduleEntry.kind
					room: scheduleEntry.room
					fromTime: scheduleEntry.fromTime
					toTime: scheduleEntry.toTime
					note: scheduleEntry.note

				ScheduleEntry.update query, updatedData, (err, numberAffected, raw) ->
					callback err, scheduleEntryFound?.id
			else
				callback err, scheduleEntryFound.id
		else
			new ScheduleEntry(scheduleEntry).save (err) ->
				console.log("New Schedule Entry synchronized: #{scheduleEntry.title}")
				callback err, scheduleEntry.id


module.exports =
	synchronize: synchronize
