logger = require 'winston'
DevoxxDataSynchronizer = require './devoxx/DevoxxDataSynchronizer'

synchronize = () ->
	new DevoxxDataSynchronizer(10).synchronize()

module.exports =
	synchronize: synchronize
