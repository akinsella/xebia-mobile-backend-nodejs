utils = require '../lib/utils'
security = require '../lib/security'
passport = require 'passport'

account = (req, res) =>
	res.render 'account',
		user: req.user

loginForm = (req, res) ->
	res.render "login"

login = passport.authenticate 'local', { successRedirect: '/', failureRedirect: '/login' }

logout = (req, res) =>
	req.logout()
	res.redirect "/login"

# GET /auth/google
#   Use passport.authenticate() as route middleware to authenticate the
#   request.  The first step in Google authentication will involve redirecting
#   the user to google.com.  After authenticating, Google will redirect the
#   user back to this application at /auth/google/return
authGoogle = (req, res) =>
	res.redirect '/'
	return

# GET /auth/google/callback
#   Use passport.authenticate() as route middleware to authenticate the
#   request.  If authentication fails, the user will be redirected back to the
#   login p
# age.  Otherwise, the primary route function function will be called,
#   which, in this example, will redirect the user to the home page.
authGoogleCallback = (req, res) =>
	res.redirect '/'
	return


module.exports =
	account: account
	login: login
	loginForm: loginForm
	authGoogle: authGoogle
	authGoogleCallback: authGoogleCallback
	logout: logout
