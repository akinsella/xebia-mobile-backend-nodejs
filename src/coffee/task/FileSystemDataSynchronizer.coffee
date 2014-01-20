logger = require 'winston'
async = require 'async'
fs = require 'fs'
util = require 'util'

utils = require '../lib/utils'
DataSynchronizer = require './DataSynchronizer'

class FileSystemDataSynchronizer extends DataSynchronizer

	constructor: (name) ->
		logger.info("Instanciating File System Data Array Synchronizer with name: '#{name}'")
		super name

	path: () -> ""

	itemTransformer: (items) -> items

	compareFields: (item) -> {}

	query: (item) -> ""

	itemDescription: (item) -> item.toString()

	createStorableItem: (item) -> item

	modelClass: () -> undefined

	synchronizeData: (callback) =>
		logger.info "Start synchronizing Data ..."
		logger.info "File path: #{@path()}"
		fs.readFile @path(), "UTF-8", (err, response) =>
			if err
				callback(err)
			else
				logger.info("Response: #{response}")
				response = JSON.parse(response)
				logger.info("Transforming response ...: #{util.inspect(response)}")
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


module.exports = FileSystemDataSynchronizer
