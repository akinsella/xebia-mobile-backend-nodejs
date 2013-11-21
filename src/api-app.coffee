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


app.get "/api/v#{config.apiVersion}/eventbrite/events", eventbrite.list
app.get "/api/v#{config.apiVersion}/eventbrite/events/:id", eventbrite.event

app.get "/api/v#{config.apiVersion}/twitter/timeline", twitter.xebia_timeline

app.get "/api/v#{config.apiVersion}/wordpress/posts/recent", wordpress.recentPosts
app.get "/api/v#{config.apiVersion}/wordpress/posts/:id", wordpress.post
app.get "/api/v#{config.apiVersion}/wordpress/authors", wordpress.authors
app.get "/api/v#{config.apiVersion}/wordpress/authors/:id", wordpress.authorPosts
app.get "/api/v#{config.apiVersion}/wordpress/tags", wordpress.tags
app.get "/api/v#{config.apiVersion}/wordpress/tags/:id", wordpress.tagPosts
app.get "/api/v#{config.apiVersion}/wordpress/categories", wordpress.categories
app.get "/api/v#{config.apiVersion}/wordpress/categories/:id", wordpress.categoryPosts
app.get "/api/v#{config.apiVersion}/wordpress/dates", wordpress.dates
app.get "/api/v#{config.apiVersion}/wordpress/:year/:month", wordpress.datePosts

app.get "/api/v#{config.apiVersion}/vimeo/oauth", vimeo.auth
app.get "/api/v#{config.apiVersion}/vimeo/oauth/callback", vimeo.callback
app.get "/api/v#{config.apiVersion}/vimeo/videos", vimeo.videos
app.get "/api/v#{config.apiVersion}/vimeo/videos/:id/urls", vimeo.videoUrls

app.get "/api/v#{config.apiVersion}/timeline", news.list
app.post "/api/v#{config.apiVersion}/devices/register", device.register

app.get "/api/v#{config.apiVersion}/essentials/cards", card.cards
app.get "/api/v#{config.apiVersion}/essentials/cards/:id", card.cardById
app.get "/api/v#{config.apiVersion}/essentials/categories", card.categories
app.get "/api/v#{config.apiVersion}/essentials/categories/:id", card.cardsByCategoryId

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
