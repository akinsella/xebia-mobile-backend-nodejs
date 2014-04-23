##################################################################################
# Imports
##################################################################################

logger = require 'winston'
_ = require('underscore')._

schedules = require './schedules'


##################################################################################
# Constants
##################################################################################

eventId = 11

##################################################################################
# Schedules
##################################################################################

tracks = (req, res) ->
	fetchTracks (err, track) ->
		res.json track unless err
		res.send 500, err.message if err



fetchTracks = (callback) ->
	uid = 0
	schedules.fetchSchedules (err, schedule) ->
		if err
			callback(err)
		else
			tracks = _.uniq(
					schedule
						.map (schedule) ->
							conferenceId: eventId
							descriptionPlainText: ""
							description: ""
							name: schedule.track
						.filter (track) -> track.name
				, (track) -> track.name)

			tracks = tracks.map (track) -> _.extend({ id: ++uid }, track)

			callback(undefined, tracks)


module.exports =
	tracks: tracks
	fetchTracks: fetchTracks