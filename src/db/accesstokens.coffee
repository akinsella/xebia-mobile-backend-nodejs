utils = require '../lib/utils'
_ = require('underscore')._
apn = require 'apn'
AccessToken = require "../model/accessToken"

exports.find = (token, done) ->
	AccessToken.find { token: token }, (err, accessToken) ->
		if (err)
			done err, null
		else
			done null, accessToken

exports.save = (token, userID, clientID, done) ->
	accessToken = new AccessToken({
		userID: userID,
		clientID: clientID
	})

	accessToken.save (err) ->
		if (err)
			done err
		else
			done null

