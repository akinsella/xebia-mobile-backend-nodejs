util = require 'util'
async = require 'async'
request = require 'request'
OAuth = require 'oauth'
_ = require('underscore')._

Cache = require '../lib/cache'
utils = require '../lib/utils'
PresentationType = require '../model/presentationType'
ExperienceLevel = require '../model/experienceLevel'
Track = require '../model/track'
Speaker = require '../model/speaker'
Presentation = require '../model/presentation'

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

module.exports =
	presentationTypes: presentationTypes
	experienceLevels: experienceLevels
	tracks: tracks
	speakers: speakers
	presentations: presentations
