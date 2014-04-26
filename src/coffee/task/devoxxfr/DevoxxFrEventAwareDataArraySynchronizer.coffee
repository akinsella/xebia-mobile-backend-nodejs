logger = require 'winston'

DevoxxFrDataArraySynchronizer = require './DevoxxFrDataArraySynchronizer'

class DevoxxFrEventAwareDataArraySynchronizer extends DevoxxFrDataArraySynchronizer

	constructor: (@name, @eventId, @conferenceName, @year) ->
		logger.info("Instanciating #{conferenceName} #{year} Event Aware Data Array Synchronizer with name: '#{@name}' and eventId: '#{@eventId}'")
		super name, conferenceName, year

	baseUrl: () ->
		"http://backend.mobile.xebia.io/mashup/conferences/#{@conferenceName}/#{@year}"
#		"http://dev.xebia.fr:8001/mashup/conferences/#{@conferenceName}/#{@year}"

module.exports = DevoxxFrEventAwareDataArraySynchronizer
