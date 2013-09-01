utils = require '../lib/utils'
security = require '../lib/security'
passport = require 'passport'

account = (req, res) =>
	res.render 'account',
		user: req.user

login = passport.authenticate 'local', (req, res) ->
    res.send 200, "User authenticated"


logout = (req, res) =>
	req.logout()
	res.send 200, "User logged out"

# GET /auth/google/callback
#   Use passport.authenticate() as route middleware to authenticate the
#   request.  If authentication fails, the user will be redirected back to the
#   login p
# age.  Otherwise, the primary route function function will be called,
#   which, in this example, will redirect the user to the home page.
authGoogleCallback = (req, res) =>
	res.redirect "/#/login"


module.exports =
	account: account
	login: login
	authGoogleCallback: authGoogleCallback
	logout: logout
