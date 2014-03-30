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

presentationTypes = (req, res) ->
	fetchPresentationTypes (err, presentationType) ->
		res.json presentationType unless err
		res.send 500, err.message if err



fetchPresentationTypes = (callback) ->
	uid = 0
	schedules.fetchSchedules (err, schedule) ->
		if err
			callback(err)
		else
			presentationTypes = _.uniq(
					schedule
						.filter (schedule) ->
							schedule.type not in ['dej', 'lunch', 'coffee', 'chgt']
						.map (schedule) ->
							conferenceId: eventId
							descriptionPlainText: ""
							description: ""
							name: schedule.type
				, (presentationType) -> presentationType.name)


			presentationTypes = presentationTypes.map (presentationType) -> _.extend({ id: ++uid }, presentationType)

			callback(undefined, presentationTypes)


module.exports =
	presentationTypes: presentationTypes
	fetchPresentationTypes: fetchPresentationTypes
