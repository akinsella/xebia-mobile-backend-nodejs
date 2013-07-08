utils = require '../lib/utils'
_ = require('underscore')._
apn = require 'apn'
User = require "../model/user"

#users = [
#	id: "1"
#	username: "bob"
#	password: "secret"
#	name: "Bob Smith"
#,
#	id: "2"
#	username: "joe"
#	password: "password"
#	name: "Joe Davis"
#]

exports.find = (id, done) ->
	User.find { id: id }, (err, user) ->
		if (err)
			done err, null
		else
			done null, user

exports.findByEmail = (email, done) ->
	User.find { email: email }, (err, user) ->
		if (err)
			done err, null
		else
			done null, user
