logger = require 'winston'
DevoxxFrDataSynchronizer = require './devoxxfr/DevoxxFrDataSynchronizer'

synchronize = (eventId, conferenceName, year) ->
	() ->
		logger.info("EventId: #{eventId}, Conference Name: #{conferenceName}, Year: #{year}")
		new DevoxxFrDataSynchronizer(eventId, conferenceName, year).synchronize()

module.exports =
	synchronize: synchronize
