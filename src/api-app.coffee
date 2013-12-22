start = new Date()

config = require './conf/config'

if config.devMode
	console.log "Dev Mode enabled."

if config.offlineMode
	console.log "Offline mode enabled."

if config.monitoring.newrelic.apiKey
	console.log "Initializing NewRelic with apiKey: '#{config.monitoring.newrelic.apiKey}'"
	newrelic = require 'newrelic'

express = require 'express'

requestLogger = require './lib/requestLogger'
allowCrossDomain = require './lib/allowCrossDomain'

twitter = require './route/twitter'
eventbrite = require './route/eventbrite'
wordpress = require './route/wordpress'
news = require './route/news'
device = require './route/device'
client = require './route/client'
vimeo = require './route/vimeo'
card = require './route/card'
conference = require './route/conference'

console.log "Application Name: #{config.appname}"
console.log "Env: #{JSON.stringify config}"

# Express
app = express()

gracefullyClosing = false

app.configure ->
	console.log "Environment: #{app.get('env')}"
	app.set 'port', config.port or process.env.PORT or 8000

#	app.use connectDomain()
	app.use (req, res, next) ->
		return next() unless gracefullyClosing
		res.setHeader "Connection", "close"
		res.send 502, "Server is in the process of restarting"

	app.use (req, res, next) ->
		req.forwardedSecure = (req.headers["x-forwarded-proto"] == "https")
		next()

	app.use express.bodyParser()
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

app.get "/api/v#{config.apiVersion}/timeline", news.listUnfiltered
app.post "/api/v#{config.apiVersion}/devices/register", device.register

app.get "/api/v#{config.apiVersion}/blog/posts/recent", wordpress.recentPosts
app.get "/api/v#{config.apiVersion}/blog/posts/:id", wordpress.post
app.get "/api/v#{config.apiVersion}/blog/authors", wordpress.authors
app.get "/api/v#{config.apiVersion}/blog/authors/:id/posts", wordpress.authorPosts
app.get "/api/v#{config.apiVersion}/blog/tags", wordpress.tags
app.get "/api/v#{config.apiVersion}/blog/tags/:id/posts", wordpress.tagPosts
app.get "/api/v#{config.apiVersion}/blog/categories", wordpress.categories
app.get "/api/v#{config.apiVersion}/blog/categories/:id/posts", wordpress.categoryPosts
app.get "/api/v#{config.apiVersion}/blog/dates", wordpress.dates
app.get "/api/v#{config.apiVersion}/blog/:year/:month/posts", wordpress.datePosts

app.get "/api/v#{config.apiVersion}/twitter/timeline", twitter.xebia_timeline

app.get "/api/v#{config.apiVersion}/events", eventbrite.list
app.get "/api/v#{config.apiVersion}/events/:id", eventbrite.event

app.get "/api/v#{config.apiVersion}/videos", vimeo.videos
app.get "/api/v#{config.apiVersion}/videos/:id", vimeo.video
app.get "/api/v#{config.apiVersion}/videos/:id/urls", vimeo.videoUrls

app.get "/api/v#{config.apiVersion}/cards", card.cards
app.get "/api/v#{config.apiVersion}/cards/categories", card.categories
app.get "/api/v#{config.apiVersion}/cards/categories/:id", card.cardsByCategoryId
app.get "/api/v#{config.apiVersion}/cards/:id", card.cardById

app.get "/api/v#{config.apiVersion}/conference/:conferenceId/experienceLevels", conference.experienceLevels
app.get "/api/v#{config.apiVersion}/conference/:conferenceId/presentationTypes", conference.presentationTypes

#app.get '/dialog/authorize', oauth2.authorization
#app.post '/dialog/authorize/decision', oauth2.decision
#app.post '/oauth/token', oauth2.token

httpServer = app.listen app.get('port')

process.on 'SIGTERM', ->
	console.log "Received kill signal (SIGTERM), shutting down gracefully."
	gracefullyClosing = true
	httpServer.close ->
		console.log "Closed out remaining connections."
		process.exit()

	setTimeout ->
		console.error "Could not close connections in time, forcefully shutting down"
		process.exit(1)
	, 30 * 1000

process.on 'uncaughtException', (err) ->
	console.error "An uncaughtException was found, the program will end. #{err}, stacktrace: #{err.stack}"
	process.exit 1

console.log "Express listening on port: #{app.get('port')}"
console.log "Started in #{(new Date().getTime() - start.getTime()) / 1000} seconds"
