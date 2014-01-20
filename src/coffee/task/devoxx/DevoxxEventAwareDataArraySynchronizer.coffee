logger = require 'winston'

DevoxxDataArraySynchronizer = require './DevoxxDataArraySynchronizer'

class DevoxxEventAwareDataArraySynchronizer extends DevoxxDataArraySynchronizer

	constructor: (@name, @eventId) ->
		logger.info("Instanciating Devoxx Event Aware Data Array Synchronizer with name: '#{@name}' and eventId: '#{@eventId}'")
		super name

	baseUrl: () ->
		"https://cfp.devoxx.com/rest/v1/events/#{@eventId}"

module.exports = DevoxxEventAwareDataArraySynchronizer
