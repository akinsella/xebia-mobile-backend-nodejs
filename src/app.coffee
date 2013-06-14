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

routes = require './routes'
github = require './routes/github'
twitter = require './routes/twitter'
eventbrite = require './routes/eventbrite'
wordpress = require './routes/wordpress'
auth = require './routes/auth'
news = require './routes/news'
device = require './routes/device'
notification = require './routes/notification'
client = require './routes/client'
user = require './routes/user'

site = require './routes/site'
oauth2 = require './oauth2'


ECT = require 'ect'
ectRenderer = ECT
	cache: true,
	watch: true,
	root:  "views"

console.log "Application Name: #{config.cf.app.name}"
console.log "Env: #{JSON.stringify config.cf}"

require './auth'

# Express
app = express()

app.configure ->
	console.log "Environment: #{app.get('env')}"
	app.set 'port', config.cf.port or process.env.PORT or 9000

	app.set 'views', "#{__dirname}/views"
	app.set 'view engine', 'ect'

	app.engine '.ect', ectRenderer.render

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

	return


app.configure 'development', () ->
	app.use express.errorHandler
		dumpExceptions: true,
		showStack: true
	return


app.configure 'production', () ->
	app.use express.errorHandler()
	return


app.get '/', routes.index

app.get '/api/eventbrite/list', eventbrite.list

app.get '/api/github/orgs/xebia-france/repos', github.repos
app.get '/api/github/orgs/xebia-france/public_members', github.public_members

app.get '/api/twitter/auth/stream/XebiaFr', twitter.stream_xebiafr
app.get '/api/twitter/auth/user/:user', twitter.user_timeline_authenticated
app.get '/api/twitter/user/:user', twitter.user_timeline

app.get '/api/wordpress/post/recent', wordpress.recentPosts
app.get '/api/wordpress/post/:id', wordpress.post
app.get '/api/wordpress/authors', wordpress.authors
app.get '/api/wordpress/author/:author', wordpress.authorPosts
app.get '/api/wordpress/tags', wordpress.tags
app.get '/api/wordpress/tag/:tag', wordpress.tagPosts
app.get '/api/wordpress/categories', wordpress.categories
app.get '/api/wordpress/category/:category', wordpress.categoryPosts
app.get '/api/wordpress/dates', wordpress.dates
app.get '/api/wordpress/:year/:month', wordpress.datePosts

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

app.get '/api/user/me', passport.authenticate("bearer", session: false ), user.me


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


#app.get '*', routes.index

process.on 'SIGTERM', () =>
	console.log 'Got SIGTERM exiting...'
	# do some cleanup here
	process.exit 0

process.on 'uncaughtException', (err) ->
	console.error "An uncaughtException was found, the program will end. #{err}, stacktrace: #{err.stack}"
	process.exit 1


console.log "Express listening on port: #{app.get('port')}"
app.listen app.get('port')

console.log 'Initializing xebia-mobile-backend application'
