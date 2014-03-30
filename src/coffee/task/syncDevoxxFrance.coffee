logger = require 'winston'
DevoxxFrDataSynchronizer = require './devoxxfr/DevoxxFrDataSynchronizer'

synchronize = () ->
	new DevoxxFrDataSynchronizer(11).synchronize()

module.exports =
	synchronize: synchronize
