fs = require 'fs'
util = require 'util'
async = require 'async'
request = require 'request'
OAuth = require 'oauth'
_ = require('underscore')._
moment = require('moment-timezone')

Cache = require '../lib/cache'
utils = require '../lib/utils'

Conference = require '../model/conference'
PresentationType = require '../model/presentationType'
ExperienceLevel = require '../model/experienceLevel'
Track = require '../model/track'
Speaker = require '../model/speaker'
Presentation = require '../model/presentation'
Room = require '../model/room'
ScheduleEntry = require '../model/scheduleEntry'
Rating = require '../model/rating'

roomsWithBeacons = JSON.parse(fs.readFileSync("#{__dirname}/../data/roomsWithBeacons.json"))

conferences = (req, res) ->
	Conference.find().sort("-from").exec (err, conferences) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			conferences = conferences.map (conference) ->
				conference = conference.toObject()
				delete conference._id
				delete conference.__v
				conference
			res.jsonp conferences


storeRating = (req, res) ->
	if req.get('content-type').indexOf('application/json') < 0
		res.json 500, { message: "Server error: content-type 'application/json' is missing" }
	else if req.body == undefined
		res.json 500, { message: "Server error: json body required" }
	else
		conferenceId = req.params.conferenceId
		if (_.isArray(req.body))
			ratings = req.body
				.filter (rating) ->
					!rating.conferenceId || Number(rating.conferenceId) == Number(conferenceId)
				.map (rating) ->
					rating.conferenceId = conferenceId
					rating.date = moment(rating.date, "YYYY-MM-DD HH:mm:ssZZ", "Europe/Paris")
					new Rating(rating)
			Rating.create ratings, (err) ->
				if (err)
					res.json 500, { message: "Server error: #{err.message}" }
				else
					res.jsonp 201, ratings.map (rating) ->
						rating = rating.toObject()
						rating.date = moment(rating.date).tz("Europe/Paris").format("YYYY-MM-DD HH:mm:ssZZ")
						delete rating.__v
						delete rating._id
						rating
		else
			rating = req.body
			if rating.conferenceId && Number(rating.conferenceId) != Number(conferenceId)
				res.json 500, { message: "Server error: conferenceId is not matching: '#{rating.conferenceId}' != '#{conferenceId}'" }
			else
				rating.date = moment(rating.date, "YYYY-MM-DD HH:mm:ssZZ", "Europe/Paris")
				rating = new Rating(rating)
				rating.save (err) ->
					if (err)
						res.json 500, { message: "Server error: #{err.message}" }
					else
						rating = rating.toObject()
						rating.date = moment(rating.date).tz("Europe/Paris").format("YYYY-MM-DD HH:mm:ssZZ")
						delete rating.__v
						delete rating._id
						res.jsonp 201, rating


ratings = (req, res) ->
	conferenceId = req.params.conferenceId
	Rating.find { conferenceId: conferenceId }, (err, fetchedRatings) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			res.jsonp fetchedRatings.map (rating) ->
				rating = rating.toObject()
				delete rating.__v
				delete rating._id
				rating

tracks = (req, res) ->
	conferenceId = req.params.conferenceId
	Track.find({ conferenceId: conferenceId }).sort("name").exec (err, tracks) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			tracks = tracks.map (track) ->
				track = track.toObject()
				delete track._id
				delete track.__v
				track
			res.jsonp tracks

presentationTypes = (req, res) ->
	conferenceId = req.params.conferenceId
	PresentationType.find({ conferenceId: conferenceId }).sort("name").exec (err, presentationTypes) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			presentationTypes = presentationTypes.map (presentationType) ->
				presentationType = presentationType.toObject()
				delete presentationType._id
				delete presentationType.__v
				presentationType
			res.jsonp presentationTypes

experienceLevels = (req, res) ->
	conferenceId = req.params.conferenceId
	ExperienceLevel.find({ conferenceId: conferenceId }).sort("name").exec (err, experienceLevels) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			experienceLevels = experienceLevels.map (experienceLevel) ->
				experienceLevel = experienceLevel.toObject()
				delete experienceLevel._id
				delete experienceLevel.__v
				experienceLevel
			res.jsonp experienceLevels

speakers = (req, res) ->
	conferenceId = req.params.conferenceId
	Speaker.find({ conferenceId: conferenceId }).sort("firstName,lastName").exec (err, speakers) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			speakers = speakers.map (speaker) ->
				speaker = speaker.toObject()
				delete speaker._id
				delete speaker.__v
				speaker.talks.forEach (talk) ->
					delete talk._id
				speaker
			res.jsonp speakers

presentations = (req, res) ->
	conferenceId = req.params.conferenceId
	Presentation.find({ conferenceId: conferenceId }).sort("title").exec (err, presentations) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			presentations = presentations.map (presentation) ->
				presentation = presentation.toObject()
				delete presentation._id
				delete presentation.__v
				presentation.speakers.forEach (speaker) ->
					delete speaker._id
				presentation.tags.forEach (tag) ->
					delete tag._id
				if conferenceId == "12"
					presentation.fromTime = moment(presentation.fromTime).tz("Europe/Paris").add("h", 1).format("YYYY-MM-DD HH:mm:ss")
					presentation.toTime = moment(presentation.toTime).tz("Europe/Paris").add("h", 1).format("YYYY-MM-DD HH:mm:ss")
				else
					presentation.fromTime = moment(presentation.fromTime).format("YYYY-MM-DD HH:mm:ss")
					presentation.toTime = moment(presentation.toTime).format("YYYY-MM-DD HH:mm:ss")
				presentation
			res.jsonp presentations

rooms = (req, res) ->
	conferenceId = req.params.conferenceId
	Room.find({ conferenceId: conferenceId }).sort("name").exec (err, rooms) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			rooms = rooms.map (room) ->
				room = room.toObject()
				delete room._id
				delete room.__v

				roomWithBeacons = _(roomsWithBeacons).find (roomWithBeacons) ->
					roomWithBeacons.conferenceId == room.conferenceId && roomWithBeacons.roomId == room.id
				if roomWithBeacons
					room.beacons = roomWithBeacons.beacons

				room
			res.jsonp rooms

schedule = (req, res) ->
	conferenceId = req.params.conferenceId
	ScheduleEntry.find({ conferenceId: conferenceId }).sort("fromTime").exec (err, scheduleEntries) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			scheduleEntries = scheduleEntries.map (scheduleEntry) ->
				scheduleEntry = scheduleEntry.toObject()
				delete scheduleEntry._id
				delete scheduleEntry.__v
				scheduleEntry.speakers.forEach (speaker) ->
					delete speaker._id
				if conferenceId == "12"
					scheduleEntry.fromTime = moment(scheduleEntry.fromTime).tz("Europe/Paris").add("h", 1).format("YYYY-MM-DD HH:mm:ss")
					scheduleEntry.toTime = moment(scheduleEntry.toTime).tz("Europe/Paris").add("h", 1).format("YYYY-MM-DD HH:mm:ss")
				else
					scheduleEntry.fromTime = moment(scheduleEntry.fromTime).format("YYYY-MM-DD HH:mm:ss")
					scheduleEntry.toTime = moment(scheduleEntry.toTime).format("YYYY-MM-DD HH:mm:ss")
				scheduleEntry

			res.jsonp scheduleEntries

scheduleByDate = (req, res) ->
	conferenceId = req.params.conferenceId
	date = moment(req.params.date, "YYYY-MM-DD")
	dateStart = moment(date).hours(0).minutes(0).seconds(0);
	dateEnd = moment(date).add('days', 1).hours(0).minutes(0).seconds(0);

	ScheduleEntry.find({ conferenceId: conferenceId, fromTime: { $gte: dateStart, $lte: dateEnd }}).sort("fromTime").exec (err, scheduleEntries) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			scheduleEntries = scheduleEntries.map (scheduleEntry) ->
				scheduleEntry = scheduleEntry.toObject()
				delete scheduleEntry._id
				delete scheduleEntry.__v
				scheduleEntry.speakers.forEach (speaker) ->
					delete speaker._id
				if conferenceId == "12"
					scheduleEntry.fromTime = moment(scheduleEntry.fromTime).tz("Europe/Paris").add("h", 1).format("YYYY-MM-DD HH:mm:ss")
					scheduleEntry.toTime = moment(scheduleEntry.toTime).tz("Europe/Paris").add("h", 1).format("YYYY-MM-DD HH:mm:ss")
				else
					scheduleEntry.fromTime = moment(scheduleEntry.fromTime).format("YYYY-MM-DD HH:mm:ss")
					scheduleEntry.toTime = moment(scheduleEntry.toTime).format("YYYY-MM-DD HH:mm:ss")
				scheduleEntry

			res.jsonp scheduleEntries

module.exports =
	conferences: conferences
	presentationTypes: presentationTypes
	experienceLevels: experienceLevels
	tracks: tracks
	speakers: speakers
	presentations: presentations
	rooms: rooms
	schedule: schedule
	scheduleByDate: scheduleByDate
	storeRating: storeRating
	ratings: ratings
