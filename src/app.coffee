fs = require 'fs'
path = require 'path'
util = require 'util'
express = require 'express'

MongoStore = require('connect-mongo')(express)
mongo = require './lib/mongo'

passport = require 'passport'
login = require 'connect-ensure-login'

requestLogger = require './lib/requestLogger'
allowCrossDomain = require './lib/allowCrossDomain'
utils = require './lib/utils'
security = require './lib/security'

config = require './conf/config'

route = require './route'
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
site = require './route/site'
oauth2 = require './oauth2'


ECT = require 'ect'
ectRenderer = ECT
	cache: true,
	watch: true,
	root: "views"

console.log "Application Name: #{config.cf.app.name}"
console.log "Env: #{JSON.stringify config.cf}"

require './auth'

# Express
app = express()

gracefullyClosing = false

cacheMiddleware = (seconds) -> (req, res, next) ->
    res.setHeader "Cache-Control", "public, max-age=#{seconds}"
    next()


app.configure ->
	console.log "Environment: #{app.get('env')}"
	app.set 'port', config.cf.port or process.env.PORT or 8000

	app.set 'views', "#{__dirname}/views"
	app.set 'view engine', 'ect'

	app.engine '.ect', ectRenderer.render

	app.use (req, res, next) ->
		return next() unless gracefullyClosing
		res.setHeader "Connection", "close"
		res.send 502, "Server is in the process of restarting"

	app.use (req, res, next) ->
		req.forwardedSecure = (req.headers["x-forwarded-proto"] == "https")
		next()

	app.use '/images', express.static("#{__dirname}/public/images")
	app.use '/scripts', express.static("#{__dirname}/public/scripts")
	app.use '/styles', express.static("#{__dirname}/public/styles")

	app.use express.favicon()
	app.use express.bodyParser()
	app.use express.cookieParser()
	app.use express.session(
		secret: config.cf.app.instance_id,
		maxAge: new Date(Date.now() + 3600000),
		store: new MongoStore(
			db: config.mongoConfig.credentials.name,
			host: config.mongoConfig.credentials.host,
			port: config.mongoConfig.credentials.port,
			username: config.mongoConfig.credentials.username,
			password: config.mongoConfig.credentials.password,
			collection: "sessions",
			auto_reconnect: true
		)
	)
	app.use express.logger()
	app.use express.methodOverride()
	app.use allowCrossDomain()

	app.set 'running in cloud', config.cf.cloud
	app.use requestLogger()

	# Initialize Passport!  Also use passport.session() middleware, to support
	# persistent login sessions (recommended).
	app.use passport.initialize()
	app.use passport.session()

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


app.get '/', route.index

app.get '/api/eventbrite/list', eventbrite.list

app.get '/api/github/orgs/xebia-france/repos', github.repos
app.get '/api/github/orgs/xebia-france/public_members', github.public_members

# app.get '/api/twitter/auth/stream/XebiaFr', twitter.stream_xebiafr
# app.get '/api/twitter/auth/user/:user', twitter.user_timeline_authenticated
#app.get '/api/twitter/user/:user', twitter.user_timeline
app.get '/api/twitter/timeline', twitter.xebia_timeline

app.get '/api/wordpress/post/recent', wordpress.recentPosts
app.get '/api/wordpress/post/:id', wordpress.post
app.get '/api/wordpress/author', wordpress.authors
app.get '/api/wordpress/author/:author', wordpress.authorPosts
app.get '/api/wordpress/tag', wordpress.tags
app.get '/api/wordpress/tag/:tag', wordpress.tagPosts
app.get '/api/wordpress/category', wordpress.categories
app.get '/api/wordpress/category/:category', wordpress.categoryPosts
app.get '/api/wordpress/dates', wordpress.dates
app.get '/api/wordpress/:year/:month', wordpress.datePosts


app.get '/api/vimeo/oauth', vimeo.auth
app.get '/api/vimeo/oauth/callback', vimeo.callback
app.get '/api/vimeo/video', vimeo.videos


app.delete '/api/news/:id', news.removeById
app.post '/api/news', news.create
app.get '/api/news/list', news.list
app.get '/api/news/:id', news.findById

app.delete '/api/device/:id', device.removeById
app.post '/api/device', device.create
app.get '/api/device/list', device.list
app.get '/api/device/:id', device.findById

app.delete '/api/client/:id', client.removeById
app.post '/api/client', client.create
app.get '/api/client/list', client.list
app.get '/api/client/:id', client.findById

app.delete '/api/user/:id', user.removeById
app.post '/api/user', user.create
app.get '/api/user/list', user.list
app.get '/api/user/:id', user.findById

app.delete '/api/notification', notification.removeById
app.post '/api/notification', notification.create
app.get '/api/notification/list', notification.list
app.get '/api/notification/:id', notification.findById
app.get 'api/notification/push', notification.push

app.get '/api/user/me', passport.authenticate("bearer", session: false), user.me

app.get('/', site.index);
app.get('/login', site.loginForm);
app.post('/login', site.login);
app.get('/logout', site.logout);
app.get('/account', login.ensureLoggedIn(), site.account);

app.get('/dialog/authorize', oauth2.authorization);
app.post('/dialog/authorize/decision', oauth2.decision);
app.post('/oauth/token', oauth2.token);

app.get('/api/user/me', user.me);

app.get '/auth/account', security.ensureAuthenticated, auth.account
app.get '/auth/login', auth.login
app.get '/auth/google', passport.authenticate('google', { failureRedirect: '/login' }), auth.authGoogle
app.get '/auth/google/callback', passport.authenticate('google', { failureRedirect: '/login' }), auth.authGoogleCallback
app.get '/auth/logout', auth.logout

#app.get '*', route.index


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
