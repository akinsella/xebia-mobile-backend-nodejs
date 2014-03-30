logger = require 'winston'
DevoxxBeDataSynchronizer = require './devoxxbe/DevoxxBeDataSynchronizer'

synchronize = () ->
	new DevoxxBeDataSynchronizer(10).synchronize()

module.exports =
	synchronize: synchronize
