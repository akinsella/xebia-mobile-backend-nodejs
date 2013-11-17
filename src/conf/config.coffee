underscore = require 'underscore'
_ = underscore._

if !config
	localConfig =
		apiVersion: process.env.API_VERSION
		offlineMode: process.env.OFFLINE_MODE == "true"
		hostname: process.env.APP_HOSTNAME
		port: process.env.APP_HTTP_PORT
		appname: 'xebia-mobile-backend.helyx.org'
		devMode: process.env.DEV_MODE == "true"
		verbose: true
		processNumber: process.env.INDEX_OF_PROCESS || 0
		scheduler:
			syncWordpress:
#				cron: '0 0,15,30,45 * * * 1-7'
				cron: '0,30 * * * * 1-7'
				timezone: "Europe/Paris"
				runOnStart: true
			syncTwitter:
				cron: '0 0,15,30,45 * * * 1-7'
#				cron: '0,30 * * * * 1-7'
				timezone: "Europe/Paris"
				runOnStart: true
			syncEventBrite:
				cron: '0 0,15,30,45 * * * 1-7'
#				cron: '0,30 * * * * 1-7'
				timezone: "Europe/Paris"
				runOnStart: true
			syncVimeo:
				cron: '0 0,15,30,45 * * * 1-7'
#				cron: '0,30 * * * * 1-7'
				timezone: "Europe/Paris"
				runOnStart: true
		auth:
			google:
				callbackUrl: process.env.AUTH_GOOGLE_CALLBACK_URL
				realm: process.env.AUTH_GOOGLE_REALM
		mongo:
			dbname: process.env.MONGO_DBNAME
			hostname: process.env.MONGO_HOSTNAME
			port: process.env.MONGO_PORT
			username: process.env.MONGO_USERNAME # 'xebia-mobile-backend'
			password: process.env.MONGO_PASSWORD # 'Password123'
		monitoring:
			newrelic:
				apiKey: process.env.NEW_RELIC_API_KEY
				appName: process.env.NEW_RELIC_APP_NAME
			strongOps:
				apiKey: process.env.STRONG_OPS_API_KEY
			nodetime:
				apiKey: process.env.NODETIME_API_KEY
		feature:
			stopWatch: true
	config = _.extend({}, localConfig)

module.exports =
	apiVersion: config.apiVersion
	offlineMode: config.offlineMode
	devMode: config.devMode
	verbose: config.verbose
	hostname: config.hostname
	processNumber: config.processNumber
	port: config.port
	appname: config.appname
	auth: config.auth
	uri: config.uri
	mongo: config.mongo
	monitoring: config.monitoring
	feature: config.feature
	scheduler: config.scheduler




