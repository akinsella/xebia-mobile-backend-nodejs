config = require '../conf/config'
utils = require '../lib/utils'

class DataArraySynchronizer
	constructor: (@name) ->
		console.log("Instanciating Data Synchronizer with name: '#{name}'")

	synchronize: (done) =>
		callback = (err, results) =>
			if err
				console.log "#{@name} Synchronization ended with error: #{err.message} - Error: #{err}"
			else if !results
				console.log "#{@name} Synchronization ended with no data"
			else
				console.log "#{@name} Synchronization ended with success (#{results.length} items) !"
				done(err, results)

		if config.feature.stopWatch
			callback = utils.stopWatchCallbak callback

		console.log "Start synchronizing #{@name} data ..."

		@synchronizeData(callback)

	synchronizeData: (callback) ->
		callback(null, null)

module.exports = DataArraySynchronizer