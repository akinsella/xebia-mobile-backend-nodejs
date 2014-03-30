##################################################################################
# Imports
##################################################################################

logger = require 'winston'


##################################################################################
# Schedules
##################################################################################

experienceLevels = (req, res) ->
	fetchExperienceLevels (err, presentationType) ->
		res.json presentationType unless err
		res.send 500, err.message if err



fetchExperienceLevels = (callback) ->
	callback(undefined, [])


module.exports =
	experienceLevels: experienceLevels
	fetchExperienceLevels: fetchExperienceLevels