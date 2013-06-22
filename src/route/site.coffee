###
Module dependencies.
###
passport = require 'passport'


index = (req, res) ->
	res.send "OAuth 2.0 Server"

loginForm = (req, res) ->
	res.render "login"

login = passport.authenticate "local",
	successReturnToOrRedirect: "/"
	failureRedirect: "/login"


logout = (req, res) ->
	req.logout()
	res.redirect "/"

account = (req, res) ->
	res.render "account",
		user: req.user


module.exports =
	index : index,
	account : account,
	login : login,
	loginForm : loginForm,
	logout : logout
