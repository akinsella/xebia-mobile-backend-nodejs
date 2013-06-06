fs = require 'fs'
path = require 'path'
express = require 'express'
passport = require 'passport'
util = require 'util'
GoogleStrategy = require('passport-google').Strategy
sass = require 'node-sass'
MongoStore = require('connect-mongo')(express)
mongo = require './lib/mongo'

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

ECT = require 'ect'
ectRenderer = ECT
	cache: true,
	watch: true,
	root:  "views"

console.log "Application Name: #{config.cf.app.name}"
console.log "Env: #{JSON.stringify config.cf}"

# Passport session setup.
#   To support persistent login sessions, Passport needs to be able to
#   serialize users into and deserialize users out of the session.  Typically,
#   this will be as simple as storing the user ID when serializing, and finding
#   the user by ID when deserializing.  However, since this example does not
#   have a database of user records, the complete Google profile is serialized
#   and deserialized.
passport.serializeUser((user, done) =>
	done(null, user)
)

passport.deserializeUser((obj, done) =>
	done(null, obj)
)

# Use the GoogleStrategy within Passport.
#   Strategies in passport require a `validate` function, which accept
#   credentials (in this case, an OpenID identifier and profile), and invoke a
#   callback with a user object.
passport.use(
	new GoogleStrategy({
		returnURL: 'http://localhost:9000/auth/google/return',
		realm: 'http://localhost:9000/'
	}, (identifier, profile, done) =>
		# asynchronous verification, for effect...
		process.nextTick () =>

			# To keep the example simple, the user's Google profile is returned to
			# represent the logged-in user.  In a typical application, you would want
			# to associate the Google account with a user record in your database,
			# and return that user instead.
			profile.identifier = identifier
			done(null, profile)
	)
)

# Express
app = express()

app.configure ->
	console.log "Environment: #{app.get('env')}"
	app.set 'port', config.cf.port or process.env.PORT or 9000

	# JADE
	app.set 'views', "#{__dirname}/views"
#	app.set 'view engine', 'jade'
#	app.set 'view options', {
#		layout: false,
#		pretty: true
#	}
	app.engine '.ect', ectRenderer.render

#	app.use sass.middleware
#		src: "#{__dirname}/sass",
#		dest: "#{__dirname}/public",
#		debug: false,
#		outputStyle: 'compressed'

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

app.post '/api/news/create', news.create
app.get '/api/news/list', news.list
app.get '/api/news/:id', news.item

app.get '/account', security.ensureAuthenticated, auth.account
app.get '/login', auth.login
app.get '/auth/google', passport.authenticate('google', { failureRedirect: '/login' }), auth.auth_google
app.get '/auth/google/return', passport.authenticate('google', { failureRedirect: '/login' }), auth.auth_google_return
app.get '/logout', auth.logout

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
