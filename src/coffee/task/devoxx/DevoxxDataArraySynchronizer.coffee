logger = require 'winston'
async = require 'async'
request = require 'request'

utils = require '../../lib/utils'
DataSynchronizer = require '../DataSynchronizer'

class DevoxxDataArraySynchronizer extends DataSynchronizer

	constructor: (name) ->
		logger.info("Instanciating Devoxx Data Array Synchronizer with name: '#{name}'")
		super name

	baseUrl: () -> "http://dev.cfp.devoxx.com:3000"

	path: () -> ""

	fullUrl: () -> "#{@baseUrl()}#{@path()}"

	itemTransformer: (items) -> items

	compareFields: (item) -> {}

	query: (item) -> ""

	itemDescription: (item) -> item.toString()

	createStorableItem: (item) -> item

	modelClass: () -> undefined

	synchronizeData: (callback) =>
		logger.info "Start synchronizing Devoxx Presentations ..."
		logger.info "Full Url: #{@fullUrl()}"
		request.get {url: @fullUrl(), json: true}, (error, data, response) =>
			logger.info("Transforming response ...")
			items = @itemTransformer(response)
			async.map items, @synchronizeItem, callback


	synchronizeItem: (item, callback) =>
		@modelClass().findOne @query(item), (err, itemFound) =>
			if err
				callback err
			else if itemFound
				if utils.isNotSame(item, itemFound, @compareFields())
					@modelClass().update @query(item), @updatedData(item), (err, numberAffected, raw) ->
						callback err, itemFound?.id
				else
					callback err, itemFound.id
			else
				@createStorableItem(item).save (err) =>
					logger.info("New #{@name} synchronized: #{@itemDescription(item)}")
					callback err, item.id


module.exports = DevoxxDataArraySynchronizer
