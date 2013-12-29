utils = require './utils'
_ = require('underscore')._
apn = require 'apn'
Client = require "./client"

find = (id, done) ->
	Client.find { id: id }, (err, client) ->
		done err, client

findById = (clientId, done) ->
	Client.find { clientId: clientId }, (err, client) ->
		done err, client

module.exports =
	find: find
	findById: findById