start = new Date()

logger = require 'winston'

config = require './conf/config'
vimeo = require './route/sync/vimeo'
sync = require './route/sync'

if config.devMode
	logger.info "Dev Mode enabled."

if config.offlineMode
	logger.info "Offline mode enabled."

if config.monitoring.newrelic.apiKey
	logger.info "Initializing NewRelic with apiKey: '#{config.monitoring.newrelic.apiKey}'"
	newrelic = require 'newrelic'


express = require 'express'

MongoStore = require('connect-mongo')(express)
mongo = require './lib/mongo'

passport = require 'passport'
role = require './lib/connect-roles-fixed'

security = require './lib/security'
auth = require './route/auth'
authMiddleware = require './middleware/authMiddleware'
authService = require './service/authService'

scheduler = require './task/scheduler'
scheduler.init()

requestLogger = require './lib/requestLogger'

logger.info "Application Name: #{config.appname}"
logger.info "Env: #{JSON.stringify config}"


# Express
app = express()

gracefullyClosing = false

passport.serializeUser authService.serializeUser
passport.deserializeUser authService.deserializeUser

passport.use authMiddleware.GoogleStrategy
passport.use authMiddleware.BasicStrategy
passport.use authMiddleware.ClientPasswordStrategy
passport.use authMiddleware.BearerStrategy

role.use authService.checkRoleAnonymous
role.use authService.ROLE_AGENT, authService.checkRoleAgent
role.use authService.ROLE_SUPER_AGENT, authService.checkRoleSuperAgent
role.use authService.ROLE_ADMIN, authService.checkRoleAdmin
role.setFailureHandler authService.failureHandler

app.configure ->
	logger.info "Environment: #{app.get('env')}"
	app.set 'port', config.port or process.env.PORT or 9000
	app.disable "x-powered-by"

	app.use (req, res, next) ->
		return next() unless gracefullyClosing
		res.setHeader "Connection", "close"
		res.send 502, "Server is in the process of restarting"

	app.use (req, res, next) ->
		req.forwardedSecure = (req.headers["x-forwarded-proto"] == "https")
		next()

	app.use express.json()
	app.use express.urlencoded()

	app.use express.logger()
	app.use express.methodOverride()

	app.use requestLogger()
	app.use express.cookieParser()
	app.use express.session(
		secret: process.env.SESSION_SECRET
		key: "sessionId"
		maxAge: new Date(Date.now() + 3600000)
		store: new MongoStore(
			db: config.mongo.dbname
			host: config.mongo.hostname
			port: config.mongo.port
			username: config.mongo.username
			password: config.mongo.password
			collection: "sessions"
			auto_reconnect: true
		)
	)

	# Initialize Passport!  Also use passport.session() middleware, to support
	# persistent login sessions (recommended).
	app.use passport.initialize()
	app.use passport.session()

	app.use role

	app.use app.router

	app.use (err, req, res, next) ->
		console.error "Error: #{err}, Stacktrace: #{err.stack}"
		res.send 500, "Something broke! Error: #{err}, Stacktrace: #{err.stack}"


app.configure 'development', () ->
	app.use express.errorHandler
		dumpExceptions: true,
		showStack: true


app.configure 'production', () ->
	app.use express.errorHandler()

app.get "/sync/vimeo/oauth", vimeo.auth
app.get "/sync/vimeo/oauth/callback", vimeo.callback

app.get "/sync/wordpress", security.ensureAuthenticated, sync.syncWordpress
app.get "/sync/wordpress/posts/co-authors", security.ensureAuthenticated, sync.syncWordpressPostsCoAuthors
app.get "/sync/wordpress/posts", security.ensureAuthenticated, sync.syncWordpressPosts
app.get "/sync/wordpress/news", security.ensureAuthenticated, sync.syncWordpressNews
app.delete "/sync/wordpress/data", security.ensureAuthenticated, sync.removeBlogData
app.delete "/sync/wordpress/posts", security.ensureAuthenticated, sync.removeBlogPosts

app.get "/sync/eventbrite", security.ensureAuthenticated, sync.syncEventBrite
app.get "/sync/eventbrite/news", security.ensureAuthenticated, sync.syncEventBriteNews
app.delete "/sync/events", security.ensureAuthenticated, sync.removeEvents

app.get "/sync/vimeo", security.ensureAuthenticated, sync.syncVimeo
app.get "/sync/vimeo/news", security.ensureAuthenticated, sync.syncVimeoNews
app.delete "/sync/videos", security.ensureAuthenticated, sync.removeVideos

app.get "/sync/conferences/devoxx/2010", security.ensureAuthenticated, sync.syncDevoxx10
app.get "/sync/conferences/devoxx/2011", security.ensureAuthenticated, sync.syncDevoxx11
app.get "/sync/conferences/devoxx/2012", security.ensureAuthenticated, sync.syncDevoxx12
app.get "/sync/conferences/devoxx/2013", security.ensureAuthenticated, sync.syncDevoxx13
app.get "/sync/conferences/devoxx/2014", security.ensureAuthenticated, sync.syncDevoxx14

app.get "/sync/conferences/devoxxfr/2012", security.ensureAuthenticated, sync.syncDevoxxFR12
app.get "/sync/conferences/devoxxfr/2013", security.ensureAuthenticated, sync.syncDevoxxFR13
app.get "/sync/conferences/devoxxfr/2014", security.ensureAuthenticated, sync.syncDevoxxFR14
app.get "/sync/conferences/devoxxfr/2015", security.ensureAuthenticated, sync.syncDevoxxFR15

app.get "/sync/conferences/devoxxuk/2013", security.ensureAuthenticated, sync.syncDevoxxUK13
app.get "/sync/conferences/devoxxuk/2014", security.ensureAuthenticated, sync.syncDevoxxUK14

app.get "/sync/conferences/mixit/2014", security.ensureAuthenticated, sync.syncMixIT

app.get "/sync/twitter/news", security.ensureAuthenticated, sync.syncTwitterNews

httpServer = app.listen app.get('port')

process.on 'SIGTERM', ->
	logger.info "Received kill signal (SIGTERM), shutting down gracefully."
	gracefullyClosing = true
	httpServer.close ->
		logger.info "Closed out remaining connections."
		process.exit()

	setTimeout ->
		console.error "Could not close connections in time, forcefully shutting down"
		process.exit(1)
	, 30 * 1000

process.on 'uncaughtException', (err) ->
	console.error "An uncaughtException was found, the program will end. #{err}, stacktrace: #{err.stack}"
	process.exit 1

logger.info "Express listening on port: #{app.get('port')}"
logger.info "Started in #{(new Date().getTime() - start.getTime()) / 1000} seconds"
