utils = require '../lib/utils'
_ = require('underscore')._
User = require "../model/user"
db = require "../db"

ROLE_AGENT = "ROLE_AGENT"
ROLE_SUPER_AGENT = "ROLE_SUPER_AGENT"
ROLE_ADMIN = "ROLE_ADMIN"
ROLE_ANONYMOUS = "ROLE_ANONYMOUS"

#anonymous users can only access the home page
#returning false stops any more rules from being
#considered
checkRoleAnonymous = (req, action) ->
	console.log "User is authenticated: #{req.user.isAuthenticated}"

	if (!req.user.isAuthenticated)
		return action == ROLE_ANONYMOUS
	return


#agent users can access private page, but
#they might not be the only one so we don't return
#false if the user isn't a agent
checkRoleAgent = (req, action) ->
	if req.user.role is ROLE_AGENT
		return true
	return

# super agent users can access private page, but
# they might not be the only one so we don't return
# false if the user isn't a super agent
checkRoleSuperAgent = (req, action) ->
	if req.user.role is ROLE_SUPER_AGENT
		return true
	return

#admin users can access all pages
checkRoleAdmin = (req, action) ->
	if req.user.role is ROLE_ADMIN
		return true
	return

authenticateUser = (email, password, done) ->
	db.users.findByEmail email, (err, user) ->
		return done(err)  if err
		return done(null, false) unless user
		return done(null, false) unless user.password is password
		done null, user

failureHandler = (req, res, action) ->
	if req.isAuthenticated()
		res.status 401
		res.send "Unauthorized"
	else
		res.status 403
		res.send "Forbidden"

# Passport session setup.
#   To support persistent login sessions, Passport needs to be able to
#   serialize users into and deserialize users out of the session.  Typically,
#   this will be as simple as storing the user ID when serializing, and finding
#   the user by ID when deserializing.  However, since this example does not
#   have a database of user records, the complete Google profile is serialized
#   and deserialized.
serializeUser = (user, done) =>
	googleId = utils.getParameterByName(user.identifier, "id")
	done(null, googleId)

deserializeUser = (id, done) =>
	User.find {googleId: id}, (err, user) ->
		done(err, user)

module.exports =
	authenticateUser: authenticateUser
	serializeUser: serializeUser
	deserializeUser: deserializeUser
	checkRoleAnonymous: checkRoleAnonymous
	checkRoleAdmin: checkRoleAdmin
	checkRoleSuperAgent: checkRoleSuperAgent
	checkRoleAgent: checkRoleAgent
	failureHandler: failureHandler
	ROLE_AGENT: ROLE_AGENT
	ROLE_SUPER_AGENT: ROLE_SUPER_AGENT
	ROLE_ADMIN: ROLE_ADMIN
	ROLE_ANONYMOUS: ROLE_ANONYMOUS