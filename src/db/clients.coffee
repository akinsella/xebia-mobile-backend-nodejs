utils = require '../lib/utils'
_ = require('underscore')._
apn = require 'apn'
Client = require "../model/client"

#clients = [{
#	id: "1"
#	name: "Xebia-iOS"
#	clientId: "xebia-ios"
#	clientSecret: "1L3J1K4U930J.4LKlk1J4H1J34f!13H4KJ14Hlkj;31"
#}]

exports.find = (id, done) ->
	Client.find { id: id }, (err, client) ->
		if (err)
			done err, null
		else
			done null, client

exports.findById = (clientId, done) ->
	Client.find { clientId: clientId }, (err, client) ->
		if (err)
			done err, null
		else
			done null, client
