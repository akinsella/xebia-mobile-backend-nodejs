utils = require '../lib/utils'
_ = require('underscore')._
apn = require 'apn'
AuthorizationCode = require "../model/authorizationCode"

exports.find = (code, done) ->
	AuthorizationCode.find { code: code }, (err, authorizationCode) ->
		if (err)
			done err, null
		else
			done null, authorizationCode

exports.save = (code, clientID, redirectURI, userID, done) ->
	authorizationCode = new AuthorizationCode({
		clientID: clientID,
		redirectURI: redirectURI,
		userID: userID
	})

	authorizationCode.save (err) ->
		if (err)
			done err
		else
			done null
