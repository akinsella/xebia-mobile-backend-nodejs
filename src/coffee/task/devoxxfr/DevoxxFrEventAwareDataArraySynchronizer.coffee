logger = require 'winston'

DevoxxFrDataArraySynchronizer = require './DevoxxFrDataArraySynchronizer'

class DevoxxFrEventAwareDataArraySynchronizer extends DevoxxFrDataArraySynchronizer

	constructor: (@name, @eventId) ->
		logger.info("Instanciating DevoxxFr Event Aware Data Array Synchronizer with name: '#{@name}' and eventId: '#{@eventId}'")
		super name

	baseUrl: () ->
		"http://backend.mobile.xebia.io/mashup/conferences/#{@eventId}"

module.exports = DevoxxFrEventAwareDataArraySynchronizer
