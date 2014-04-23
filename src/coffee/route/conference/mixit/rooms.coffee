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
locationName = "Marriot"



##################################################################################
# Schedules
##################################################################################

rooms = (req, res) ->
	fetchRooms (err, room) ->
		res.json room unless err
		res.send 500, err.message if err



fetchRooms = (callback) ->
	schedules.fetchSchedules (err, schedule) ->
		if err
			callback(err)
		else
			rooms = _.uniq(
				schedule.map (schedule) ->
					id: schedule.roomId
					capacity: if schedule.roomCapacity then schedule.roomCapacity else 0
					conferenceId: eventId
					locationName: locationName
					name: schedule.room
			, (room) -> room.id)

			callback(undefined, rooms)


module.exports =
	rooms: rooms
	fetchRooms: fetchRooms