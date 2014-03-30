start = new Date()

logger = require 'winston'

config = require './conf/config'

if config.devMode
	logger.info "Dev Mode enabled."

if config.offlineMode
	logger.info "Offline mode enabled."

if config.monitoring.newrelic.apiKey
	logger.info "Initializing NewRelic with apiKey: '#{config.monitoring.newrelic.apiKey}'"
	newrelic = require 'newrelic'

express = require 'express'

requestLogger = require './lib/requestLogger'
allowCrossDomain = require './lib/allowCrossDomain'


logger.info "Application Name: #{config.appname}"
logger.info "Env: #{JSON.stringify config}"

# Express
app = express()

gracefullyClosing = false

app.configure ->
	logger.info "Environment: #{app.get('env')}"
	app.set 'port', config.port or process.env.PORT or 8000

#	app.use connectDomain()
	app.use (req, res, next) ->
		return next() unless gracefullyClosing
		res.setHeader "Connection", "close"
		res.send 502, "Server is in the process of restarting"

	app.use (req, res, next) ->
		req.forwardedSecure = (req.headers["x-forwarded-proto"] == "https")
		next()

	app.use express.json()
	app.use express.urlencoded()
	app.use express.cookieParser()

	app.use express.logger()
	app.use express.methodOverride()
	app.use allowCrossDomain()

	app.use requestLogger()

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


speakers = require './route/conference/devoxxfr/speakers'
schedules = require './route/conference/devoxxfr/schedules'
presentationTypes = require './route/conference/devoxxfr/presentationTypes'
experienceLevels = require './route/conference/devoxxfr/experienceLevels'
rooms = require './route/conference/devoxxfr/rooms'
tracks = require './route/conference/devoxxfr/tracks'
presentations = require './route/conference/devoxxfr/presentations'


app.get "/mashup/conferences/11/speakers", speakers.speakers
app.get "/mashup/conferences/11/schedule", schedules.schedules
app.get "/mashup/conferences/11/presentationTypes", presentationTypes.presentationTypes
app.get "/mashup/conferences/11/experienceLevels", experienceLevels.experienceLevels
app.get "/mashup/conferences/11/rooms", rooms.rooms
app.get "/mashup/conferences/11/tracks", tracks.tracks
app.get "/mashup/conferences/11/presentations", presentations.presentations


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
