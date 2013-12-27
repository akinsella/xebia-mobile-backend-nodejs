DevoxxDataArraySynchronizer = require './DevoxxDataArraySynchronizer'

class DevoxxEventAwareDataArraySynchronizer extends DevoxxDataArraySynchronizer

	constructor: (@name, @eventId) ->
		console.log("Instanciating Devoxx Event Aware Data Array Synchronizer with name: '#{@name}' and eventId: '#{@eventId}'")
		super name

	baseUrl: () ->
		"http://dev.cfp.devoxx.com:3000/rest/v1/events/#{@eventId}"

module.exports = DevoxxEventAwareDataArraySynchronizer
