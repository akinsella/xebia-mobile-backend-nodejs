underscore = require 'underscore'
_ = underscore._

if !config
	localConfig =
		hostname: process.env.APP_HOSTNAME
		port: process.env.APP_HTTP_PORT
		appname: 'xebia-mobile-backend.helyx.org'
		devMode: process.env.DEV_MODE
		verbose: true
		processNumber: process.env.INDEX_OF_PROCESS || 0
		mongo:
			dbname: process.env.MONGO_DBNAME
			hostname: process.env.MONGO_HOSTNAME
			port: process.env.MONGO_PORT
			username: process.env.MONGO_USERNAME # 'xebia-mobile-backend'
			password: process.env.MONGO_PASSWORD # 'Password123'

		strongOps:
			apiKey: process.env.STRONG_OPS_API_KEY

	config = _.extend({}, localConfig)

module.exports =
	devMode: config.devMode
	verbose: config.verbose
	hostname: config.hostname
	processNumber: config.processNumber
	port: config.port
	appname: config.appname
	uri: config.uri
	mongo: config.mongo
	strongOps: config.strongOps




