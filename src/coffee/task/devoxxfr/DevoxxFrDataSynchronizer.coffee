logger = require 'winston'
async = require 'async'
request = require 'request'

config = require '../../conf/config'
utils = require '../../lib/utils'
DataSynchronizer = require '../DataSynchronizer'
ConferencesSynchronizer = require '../ConferencesSynchronizer'
DevoxxFrExperienceLevelsSynchronizer = require './DevoxxFrExperienceLevelsSynchronizer'
DevoxxFrPresentationTypesSynchronizer = require './DevoxxFrPresentationTypesSynchronizer'
DevoxxFrTracksSynchronizer = require './DevoxxFrTracksSynchronizer'
DevoxxFrSpeakersSynchronizer = require './DevoxxFrSpeakersSynchronizer'
DevoxxFrPresentationsSynchronizer = require './DevoxxFrPresentationsSynchronizer'
DevoxxFrRoomsSynchronizer = require './DevoxxFrRoomsSynchronizer'
DevoxxFrScheduleEntriesSynchronizer = require './DevoxxFrScheduleEntriesSynchronizer'

class DevoxxFrDataSynchronizer extends DataSynchronizer

	constructor: (@eventId) ->
		super "Instanciating DevoxxFr Data Synchronizer for eventId: #{@eventId}"

	synchronizeData: (callback) =>
		logger.info "Start synchronizing Devoxx data ..."
		callback = (err, results) ->
			if err
				logger.info "DevoxxFr Synchronization ended with error: #{err.message} - Error: #{err}"
			else
				logger.info "DevoxxFr Synchronization ended with success with #{results.length} results !"

		if config.feature.stopWatch
			callback = utils.stopWatchCallbak callback

		logger.info "Start synchronizing Devoxx data ..."

		async.parallel([
			new ConferencesSynchronizer().synchronize,
			new DevoxxFrExperienceLevelsSynchronizer(@eventId).synchronize,
			new DevoxxFrPresentationTypesSynchronizer(@eventId).synchronize,
			new DevoxxFrTracksSynchronizer(@eventId).synchronize,
			new DevoxxFrSpeakersSynchronizer(@eventId).synchronize,
			new DevoxxFrPresentationsSynchronizer(@eventId).synchronize,
			new DevoxxFrRoomsSynchronizer(@eventId).synchronize,
			new DevoxxFrScheduleEntriesSynchronizer(@eventId).synchronize
		], callback)


module.exports = DevoxxFrDataSynchronizer
