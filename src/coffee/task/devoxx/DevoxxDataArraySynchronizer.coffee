async = require 'async'
_ = require('underscore')._
request = require "request"

utils = require '../../lib/utils'

DataSynchronizer = require '../DataSynchronizer'

class DevoxxDataArraySynchronizer extends DataSynchronizer

	constructor: (name) ->
		console.log("Instanciating Devoxx Data Array Synchronizer with name: '#{name}'")
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
		console.log "Start synchronizing Devoxx Presentations ..."
		console.log "Full Url: #{@fullUrl()}"
		request.get {url: @fullUrl(), json: true}, (error, data, response) =>
			console.log("Transforming response ...")
			console.log("response: #{response}")
			items = @itemTransformer(response)
			async.map items, @synchronizeItem, callback


	synchronizeItem: (item, callback) =>
		console.log("Processing item with id: #{item.id} ...")
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
				@createStorableItem(item).save (err) ->
					console.log("New #{@name} synchronized: #{item.title}")
					callback err, item.id


module.exports = DevoxxDataArraySynchronizer
