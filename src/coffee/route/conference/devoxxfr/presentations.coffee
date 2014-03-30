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
experience = "N/D"

##################################################################################
# Schedules
##################################################################################

presentations = (req, res) ->
	fetchPresentations (err, presentation) ->
		res.json presentation unless err
		res.send 500, err.message if err



fetchPresentations = (callback) ->
	uid = 0
	schedules.fetchSchedules (err, schedule) ->
		if err
			callback(err)
		else
			presentations =
				schedule
					.filter (schedule) ->
						schedule.kind != "Break"
					.map (schedule) ->
							id: schedule.id
							conferenceId: eventId
							tags: []
							speakers: schedule.speakers.map (speaker) ->
								id: speaker.id
								uri: speaker.uri
								name: speaker.name
							room: schedule.room
							type: schedule.type
							language: schedule.language
							experience: experience
							track: schedule.track
							title: schedule.title
							summary: schedule.summary

			presentations = presentations.map (presentation) -> _.extend({ id: ++uid }, presentation)

			callback(undefined, presentations)



module.exports =
	presentations: presentations
	fetchPresentations: fetchPresentations