config = require './conf/config'

if config.devMode
	console.log "Dev Mode enabled."

if config.offlineMode
	console.log "Offline mode enabled."

#os = require 'os'
#
#if config.monitoringstrongOps.apiKey
#	console.log "Initializing StrongOps Agent with apiKey: '#{config.monitoring.strongOps.apiKey}'"
#	require('strong-agent').profile(config.monitoring.strongOps.apiKey, [config.appname, os.hostname() || config.hostname, config.processNumber], {})

#if config.monitoring.nodetime.apiKey
#	console.log "Initializing NodeTime with apiKey: '#{config.monitoring.nodetime.apiKey}'"
#	require('nodetime').profile
#		accountKey: config.monitoring.nodetime.apiKey
#		appName: config.appname

if config.monitoring.newrelic.apiKey
	console.log "Initializing NewRelic with apiKey: '#{config.monitoring.newrelic.apiKey}'"
	newrelic = require 'newrelic'

scheduler = require './task/scheduler'
scheduler.init()

fs = require 'fs'
path = require 'path'
util = require 'util'
express = require 'express'

#connectDomain = require 'connect-domain'

MongoStore = require('connect-mongo')(express)
mongo = require './lib/mongo'

passport = require 'passport'
role = require './lib/connect-roles-fixed'

requestLogger = require './lib/requestLogger'
allowCrossDomain = require './lib/allowCrossDomain'
utils = require './lib/utils'

security = require './lib/security'

github = require './route/github'
twitter = require './route/twitter'
eventbrite = require './route/eventbrite'
wordpress = require './route/wordpress'
auth = require './route/auth'
news = require './route/news'
device = require './route/device'
notification = require './route/notification'
client = require './route/client'
user = require './route/user'
vimeo = require './route/vimeo'
card = require './route/card'
oauth2 = require './oauth2'
authMiddleware = require './middleware/authMiddleware'
authService = require './service/authService'

console.log "Application Name: #{config.appname}"
console.log "Env: #{JSON.stringify config}"

# Express
app = express()

gracefullyClosing = false

#cacheMiddleware = (seconds) -> (req, res, next) ->
#    res.setHeader "Cache-Control", "public, max-age=#{seconds}"
#    next()

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

	app.use '/', express.static("#{__dirname}/public")

	app.use express.favicon()
	app.use express.bodyParser()
	app.use express.cookieParser()
	app.use express.session(
		secret: process.env.SESSION_SECRET,
		maxAge: new Date(Date.now() + 3600000),
		store: new MongoStore(
			db: config.mongo.dbname,
			host: config.mongo.hostname,
			port: config.mongo.port,
			username: config.mongo.username,
			password: config.mongo.password,
			collection: "sessions",
			auto_reconnect: true
		)
	)
	app.use express.logger()
	app.use express.methodOverride()
	app.use allowCrossDomain()

	app.use requestLogger()

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

app.get '/api/eventbrite/events', eventbrite.list

app.get '/api/github/repositories', github.repos
app.get '/api/github/members', github.public_members

app.get '/api/twitter/timeline', twitter.xebia_timeline

app.get '/api/wordpress/posts/recent', wordpress.recentPosts
app.get '/api/wordpress/posts/:id', wordpress.post
app.get '/api/wordpress/authors', wordpress.authors
app.get '/api/wordpress/authors/:id', wordpress.authorPosts
app.get '/api/wordpress/tags', wordpress.tags
app.get '/api/wordpress/tags/:id', wordpress.tagPosts
app.get '/api/wordpress/categories', wordpress.categories
app.get '/api/wordpress/categories/:id', wordpress.categoryPosts
app.get '/api/wordpress/dates', wordpress.dates
app.get '/api/wordpress/:year/:month', wordpress.datePosts


app.get '/api/vimeo/oauth', vimeo.auth
app.get '/api/vimeo/oauth/callback', vimeo.callback
app.get '/api/vimeo/videos', vimeo.videos


app.delete '/api/news/:id', news.removeById
app.post '/api/news', news.create
app.get '/api/news', news.list
app.get '/api/news', news.listUnfiltered
app.get '/api/news/:id', news.findById

app.delete '/api/devices/:id', device.removeById
app.post '/api/devices', device.create
app.get '/api/devices', device.list
app.get '/api/devices/:id', device.findById

app.delete '/api/clients/:id', client.removeById
app.post '/api/clients', client.create
app.get '/api/clients', client.list
app.get '/api/clients/:id', client.findById

app.post '/api/users', user.create
app.get '/api/users', user.list
app.get '/api/users/me', security.ensureAuthenticated, user.me
app.get '/api/users/:id', user.findById
app.delete '/api/users/:id', user.removeById

app.get '/api/essentials/cards', card.cards
app.get '/api/essentials/cards/:id', card.cardById
app.get '/api/essentials/categories', card.categories
app.get '/api/essentials/categories/:id', card.cardsByCategoryId

app.delete '/api/notifications', notification.removeById
app.post '/api/notifications', notification.create
app.get '/api/notifications', notification.list
app.get '/api/notifications/:id', notification.findById
app.get 'api/notifications/push', notification.push

#app.get '/api/user/me', passport.authenticate("bearer", session: false), user.me

app.post '/login', auth.login
app.get '/login', auth.loginForm
app.get '/logout', auth.logout

app.get '/auth/google', passport.authenticate('google', { failureRedirect: '/#/login' })
app.get '/auth/google/callback', passport.authenticate('google', { failureRedirect: '/#/login' }), auth.authGoogleCallback

app.get '/dialog/authorize', oauth2.authorization
app.post '/dialog/authorize/decision', oauth2.decision
app.post '/oauth/token', oauth2.token


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
