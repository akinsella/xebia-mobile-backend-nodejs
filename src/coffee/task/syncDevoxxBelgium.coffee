logger = require 'winston'
DevoxxBeDataSynchronizer = require './devoxxbe/DevoxxBeDataSynchronizer'

synchronize = (eventId, year) ->
	() ->
		new DevoxxBeDataSynchronizer(eventId, "devoxxbe", year).synchronize()

module.exports =
	synchronize: synchronize
