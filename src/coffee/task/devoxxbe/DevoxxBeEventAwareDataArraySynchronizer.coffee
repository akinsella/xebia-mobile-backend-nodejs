logger = require 'winston'

DevoxxBeDataArraySynchronizer = require './DevoxxBeDataArraySynchronizer'

class DevoxxBeEventAwareDataArraySynchronizer extends DevoxxBeDataArraySynchronizer

	constructor: (@name, @eventId) ->
		logger.info("Instanciating DevoxxBe Event Aware Data Array Synchronizer with name: '#{@name}' and eventId: '#{@eventId}'")
		super name

	baseUrl: () ->
		"https://cfp.devoxx.com/rest/v1/events/#{@eventId}"

module.exports = DevoxxBeEventAwareDataArraySynchronizer
