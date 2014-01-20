logger = require 'winston'
async = require 'async'
request = require 'request'

config = require '../../conf/config'
utils = require '../../lib/utils'
DataSynchronizer = require '../DataSynchronizer'
ConferencesSynchronizer = require '../ConferencesSynchronizer'
DevoxxExperienceLevelsSynchronizer = require './DevoxxExperienceLevelsSynchronizer'
DevoxxPresentationTypesSynchronizer = require './DevoxxPresentationTypesSynchronizer'
DevoxxTracksSynchronizer = require './DevoxxTracksSynchronizer'
DevoxxSpeakersSynchronizer = require './DevoxxSpeakersSynchronizer'
DevoxxPresentationsSynchronizer = require './DevoxxPresentationsSynchronizer'
DevoxxRoomsSynchronizer = require './DevoxxRoomsSynchronizer'
DevoxxScheduleEntriesSynchronizer = require './DevoxxScheduleEntriesSynchronizer'

class DevoxxDataSynchronizer extends DataSynchronizer

	constructor: (@eventId) ->
		super "Instanciating Devoxx Data Synchronizer for eventId: #{@eventId}"

	synchronizeData: (callback) =>
		logger.info "Start synchronizing Devoxx data ..."
		callback = (err, results) ->
			if err
				logger.info "Devoxx Synchronization ended with error: #{err.message} - Error: #{err}"
			else
				logger.info "Devoxx Synchronization ended with success with #{results.length} results !"

		if config.feature.stopWatch
			callback = utils.stopWatchCallbak callback

		logger.info "Start synchronizing Devoxx data ..."

		async.parallel([
			new ConferencesSynchronizer().synchronize,
			new DevoxxExperienceLevelsSynchronizer(@eventId).synchronize,
			new DevoxxPresentationTypesSynchronizer(@eventId).synchronize,
			new DevoxxTracksSynchronizer(@eventId).synchronize,
			new DevoxxSpeakersSynchronizer(@eventId).synchronize,
			new DevoxxPresentationsSynchronizer(@eventId).synchronize,
			new DevoxxRoomsSynchronizer(@eventId).synchronize,
			new DevoxxScheduleEntriesSynchronizer(@eventId).synchronize
		], callback)


module.exports = DevoxxDataSynchronizer
