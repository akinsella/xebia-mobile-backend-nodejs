start = new Date()

logger = require 'winston'
Q = require 'q'

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
	app.disable "x-powered-by"

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


devoxxfrSpeakers = require './route/conference/devoxxfr/speakers'
devoxxfrSchedule = require './route/conference/devoxxfr/schedules'
devoxxfrPresentationTypes = require './route/conference/devoxxfr/presentationTypes'
devoxxfrExperienceLevels = require './route/conference/devoxxfr/experienceLevels'
devoxxfrRooms = require './route/conference/devoxxfr/rooms'
devoxxfrTracks = require './route/conference/devoxxfr/tracks'
devoxxfrPresentations = require './route/conference/devoxxfr/presentations'


devoxxukSpeakers = require './route/conference/devoxxfr/speakers'
devoxxukSchedule = require './route/conference/devoxxfr/schedules'
devoxxukPresentationTypes = require './route/conference/devoxxfr/presentationTypes'
devoxxukExperienceLevels = require './route/conference/devoxxfr/experienceLevels'
devoxxukRooms = require './route/conference/devoxxfr/rooms'
devoxxukTracks = require './route/conference/devoxxfr/tracks'
devoxxukPresentations = require './route/conference/devoxxfr/presentations'

devoxxSpeakers = require './route/conference/devoxx/speakers'
devoxxSchedule = require './route/conference/devoxx/schedules'
devoxxPresentationTypes = require './route/conference/devoxx/presentationTypes'
devoxxExperienceLevels = require './route/conference/devoxx/experienceLevels'
devoxxRooms = require './route/conference/devoxx/rooms'
devoxxTracks = require './route/conference/devoxx/tracks'
devoxxPresentations = require './route/conference/devoxx/presentations'

mixitSpeakers = require './route/conference/mixit/speakers'
mixitSchedule = require './route/conference/mixit/schedules'
mixitRooms = require './route/conference/mixit/rooms'
mixitTracks = require './route/conference/mixit/tracks'
mixitPresentationTypes = require './route/conference/mixit/presentationTypes'
mixitExperienceLevels = require './route/conference/mixit/experienceLevels'
mixitPresentations = require './route/conference/mixit/presentations'


app.get "/mashup/conferences/devoxxfr/2014/speakers", devoxxfrSpeakers.speakers
app.get "/mashup/conferences/devoxxfr/2014/schedule", devoxxfrSchedule.schedules
app.get "/mashup/conferences/devoxxfr/2014/presentationTypes", devoxxfrPresentationTypes.presentationTypes
app.get "/mashup/conferences/devoxxfr/2014/experienceLevels", devoxxfrExperienceLevels.experienceLevels
app.get "/mashup/conferences/devoxxfr/2014/rooms", devoxxfrRooms.rooms
app.get "/mashup/conferences/devoxxfr/2014/tracks", devoxxfrTracks.tracks
app.get "/mashup/conferences/devoxxfr/2014/presentations", devoxxfrPresentations.presentations


app.get "/mashup/conferences/devoxxfr/2015/speakers", devoxxfrSpeakers.speakers
app.get "/mashup/conferences/devoxxfr/2015/schedule", devoxxfrSchedule.schedules
app.get "/mashup/conferences/devoxxfr/2015/presentationTypes", devoxxfrPresentationTypes.presentationTypes
app.get "/mashup/conferences/devoxxfr/2015/experienceLevels", devoxxfrExperienceLevels.experienceLevels
app.get "/mashup/conferences/devoxxfr/2015/rooms", devoxxfrRooms.rooms
app.get "/mashup/conferences/devoxxfr/2015/tracks", devoxxfrTracks.tracks
app.get "/mashup/conferences/devoxxfr/2015/presentations", devoxxfrPresentations.presentations



app.get "/mashup/conferences/devoxxuk/2015/speakers", devoxxukSpeakers.speakers
app.get "/mashup/conferences/devoxxuk/2015/schedule", devoxxukSchedule.schedules
app.get "/mashup/conferences/devoxxuk/2015/presentationTypes", devoxxukPresentationTypes.presentationTypes
app.get "/mashup/conferences/devoxxuk/2015/experienceLevels", devoxxukExperienceLevels.experienceLevels
app.get "/mashup/conferences/devoxxuk/2015/rooms", devoxxukRooms.rooms
app.get "/mashup/conferences/devoxxuk/2015/tracks", devoxxukTracks.tracks
app.get "/mashup/conferences/devoxxuk/2015/presentations", devoxxukPresentations.presentations

app.get "/mashup/conferences/devoxxbe/2014/speakers", devoxxSpeakers.speakers
app.get "/mashup/conferences/devoxxbe/2014/schedule", devoxxSchedule.schedules
app.get "/mashup/conferences/devoxxbe/2014/presentationTypes", devoxxPresentationTypes.presentationTypes
app.get "/mashup/conferences/devoxxbe/2014/experienceLevels", devoxxExperienceLevels.experienceLevels
app.get "/mashup/conferences/devoxxbe/2014/rooms", devoxxRooms.rooms
app.get "/mashup/conferences/devoxxbe/2014/tracks", devoxxTracks.tracks
app.get "/mashup/conferences/devoxxbe/2014/presentations", devoxxPresentations.presentations

app.get "/mashup/conferences/mixit/2014/speakers", mixitSpeakers.speakers
app.get "/mashup/conferences/mixit/2014/schedule", mixitSchedule.schedules
app.get "/mashup/conferences/mixit/2014/presentationTypes", mixitPresentationTypes.presentationTypes
app.get "/mashup/conferences/mixit/2014/experienceLevels", mixitExperienceLevels.experienceLevels
app.get "/mashup/conferences/mixit/2014/rooms", mixitRooms.rooms
app.get "/mashup/conferences/mixit/2014/tracks", mixitTracks.tracks
app.get "/mashup/conferences/mixit/2014/presentations", mixitPresentations.presentations

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
