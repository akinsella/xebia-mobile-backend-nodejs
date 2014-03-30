logger = require 'winston'
async = require 'async'
request = require 'request'

config = require '../../conf/config'
utils = require '../../lib/utils'
DataSynchronizer = require '../DataSynchronizer'
ConferencesSynchronizer = require '../ConferencesSynchronizer'
DevoxxBeExperienceLevelsSynchronizer = require './DevoxxBeExperienceLevelsSynchronizer'
DevoxxBePresentationTypesSynchronizer = require './DevoxxBePresentationTypesSynchronizer'
DevoxxBeTracksSynchronizer = require './DevoxxBeTracksSynchronizer'
DevoxxBeSpeakersSynchronizer = require './DevoxxBeSpeakersSynchronizer'
DevoxxBePresentationsSynchronizer = require './DevoxxBePresentationsSynchronizer'
DevoxxBeRoomsSynchronizer = require './DevoxxBeRoomsSynchronizer'
DevoxxBeScheduleEntriesSynchronizer = require './DevoxxBeScheduleEntriesSynchronizer'

class DevoxxBeDataSynchronizer extends DataSynchronizer

	constructor: (@eventId) ->
		super "Instanciating DevoxxBe Data Synchronizer for eventId: #{@eventId}"

	synchronizeData: (callback) =>
		logger.info "Start synchronizing DevoxxBe data ..."
		callback = (err, results) ->
			if err
				logger.info "DevoxxBe Synchronization ended with error: #{err.message} - Error: #{err}"
			else
				logger.info "DevoxxBe Synchronization ended with success with #{results.length} results !"

		if config.feature.stopWatch
			callback = utils.stopWatchCallbak callback

		logger.info "Start synchronizing DevoxxBe data ..."

		async.parallel([
			new ConferencesSynchronizer().synchronize,
			new DevoxxBeExperienceLevelsSynchronizer(@eventId).synchronize,
			new DevoxxBePresentationTypesSynchronizer(@eventId).synchronize,
			new DevoxxBeTracksSynchronizer(@eventId).synchronize,
			new DevoxxBeSpeakersSynchronizer(@eventId).synchronize,
			new DevoxxBePresentationsSynchronizer(@eventId).synchronize,
			new DevoxxBeRoomsSynchronizer(@eventId).synchronize,
			new DevoxxBeScheduleEntriesSynchronizer(@eventId).synchronize
		], callback)


module.exports = DevoxxBeDataSynchronizer
