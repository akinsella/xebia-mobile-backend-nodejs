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

	constructor: (@eventId, @conferenceName, @year) ->
		super "Instanciating #{@conferenceName} #{@year} Data Synchronizer for eventId: #{@eventId}"

	synchronizeData: (callback) =>
		logger.info "Start synchronizing Devoxx data ..."
		callback = (err, results) =>
			if err
				logger.info "#{@conferenceName} #{@year} Synchronization ended with error: #{err.message} - Error: #{err}"
			else
				logger.info "#{@conferenceName} #{@year} Synchronization ended with success with #{results.length} results !"

		if config.feature.stopWatch
			callback = utils.stopWatchCallbak callback

		logger.info "Start synchronizing  #{@conferenceName} #{@year} data ..."

		async.parallel([
			new ConferencesSynchronizer().synchronize,
			new DevoxxFrExperienceLevelsSynchronizer(@eventId, @conferenceName, @year).synchronize,
			new DevoxxFrPresentationTypesSynchronizer(@eventId, @conferenceName, @year).synchronize,
			new DevoxxFrTracksSynchronizer(@eventId, @conferenceName, @year).synchronize,
			new DevoxxFrSpeakersSynchronizer(@eventId, @conferenceName, @year).synchronize,
			new DevoxxFrPresentationsSynchronizer(@eventId, @conferenceName, @year).synchronize,
			new DevoxxFrRoomsSynchronizer(@eventId, @conferenceName, @year).synchronize,
			new DevoxxFrScheduleEntriesSynchronizer(@eventId, @conferenceName, @year).synchronize
		], callback)


module.exports = DevoxxFrDataSynchronizer
