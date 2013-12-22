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

tracks = (req, res) ->
	conferenceId = req.params.conferenceId
	Track.find({ conferenceId: conferenceId }).sort("-name").exec (err, tracks) ->
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
	PresentationType.find({ conferenceId: conferenceId }).sort("-name").exec (err, presentationTypes) ->
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
	ExperienceLevel.find({ conferenceId: conferenceId }).sort("-name").exec (err, experienceLevels) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			experienceLevels = experienceLevels.map (experienceLevel) ->
				experienceLevel = experienceLevel.toObject()
				delete experienceLevel._id
				delete experienceLevel.__v
				experienceLevel
			res.json experienceLevels

module.exports =
	presentationTypes: presentationTypes
	experienceLevels: experienceLevels
	tracks: tracks
