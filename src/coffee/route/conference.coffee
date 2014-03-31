util = require 'util'
async = require 'async'
request = require 'request'
OAuth = require 'oauth'
_ = require('underscore')._
moment = require 'moment'

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
Vote = require '../model/vote'

conferences = (req, res) ->
	Conference.find().sort("name").exec (err, conferences) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			conferences = conferences.map (conference) ->
				conference = conference.toObject()
				delete conference._id
				delete conference.__v
				conference
			res.json conferences


storeVote = (req, res) ->
	if req.get('content-type') != 'application/json'
		res.json 500, { message: "Server error: content-type 'application/json' is missing" }
	else if req.body == undefined
		res.json 500, { message: "Server error: json body required" }
	else
		conferenceId = req.params.conferenceId
		if (_.isArray(req.body))
			votes = req.body
				.filter (vote) ->
					!vote.conferenceId || Number(vote.conferenceId) == Number(conferenceId)
				.map (vote) ->
					vote.conferenceId = conferenceId
					vote.date = moment(vote.date, "YYYY-MM-DD HH:mm:ss")
					new Vote(vote)
			Vote.create votes, (err) ->
				if (err)
					res.json 500, { message: "Server error: #{err.message}" }
				else
					res.json 201, votes.map (vote) ->
						vote = vote.toObject()
						delete vote.__v
						delete vote._id
						vote
		else
			vote = req.body
			if vote.conferenceId && Number(vote.conferenceId) != Number(conferenceId)
				res.json 500, { message: "Server error: conferenceId is not matching: '#{vote.conferenceId}' != '#{conferenceId}'" }
			else
				vote.date = moment(vote.date, "YYYY-MM-DD HH:mm:ss")
				vote = new Vote(vote)
				vote.save (err) ->
					if (err)
						res.json 500, { message: "Server error: #{err.message}" }
					else
						vote = vote.toObject()
						delete vote.__v
						delete vote._id
						res.json 201, vote


votes = (req, res) ->
	conferenceId = req.params.conferenceId
	Vote.find { conferenceId: conferenceId }, (err, votes) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			res.json votes

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
			res.json tracks

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
			res.json presentationTypes

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
			res.json experienceLevels

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
			res.json speakers

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
				presentation
			res.json presentations

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
				room
			res.json rooms

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
				scheduleEntry.fromTime = moment(scheduleEntry.fromTime).format("YYYY-MM-DD HH:mm:ss")
				scheduleEntry.toTime = moment(scheduleEntry.toTime).format("YYYY-MM-DD HH:mm:ss")
				scheduleEntry

			res.json scheduleEntries

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
				scheduleEntry.fromTime = moment(scheduleEntry.fromTime).format("YYYY-MM-DD HH:mm:ss")
				scheduleEntry.toTime = moment(scheduleEntry.toTime).format("YYYY-MM-DD HH:mm:ss")
				scheduleEntry

			res.json scheduleEntries

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
	storeVote: storeVote
	votes: votes
