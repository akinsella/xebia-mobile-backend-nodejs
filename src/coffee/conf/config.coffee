_ = require('underscore')._

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
				cron: '0 5 * * * 1-7'
				timezone: "Europe/Paris"
				runOnStart: true
			syncWordpressPosts:
				cron: '0 10 * * * 1-7'
				timezone: "Europe/Paris"
				runOnStart: true
			syncTwitter:
				cron: '30 */10 * * * 1-7'
				timezone: "Europe/Paris"
				runOnStart: true
			syncEventBrite:
				cron: '0 30 */2 * * 1-7'
				timezone: "Europe/Paris"
				runOnStart: true
			syncVimeo:
				cron: '0 35 20 * * 1-7'
				timezone: "Europe/Paris"
				runOnStart: true
			syncDevoxxFrance:
				cron: '0 45 20 * * 1-7'
				timezone: "Europe/Paris"
				runOnStart: true
			syncDevoxxBelgium:
				cron: '0 50 20 * * 1-7'
				timezone: "Europe/Paris"
				runOnStart: true
			syncMixIT:
				cron: '0 55 20 * * 1-7'
				timezone: "Europe/Paris"
				runOnStart: true
		auth:
			google:
				callbackUrl: process.env.AUTH_GOOGLE_CALLBACK_URL || 'http://localhost'
				realm: process.env.AUTH_GOOGLE_REALM || 'localhost'
		apns:
			enabled: process.env.APNS_ENABLED == "true"
			devMode: process.env.APNS_SANDBOX_ENABLED == "true"
			certFile: process.env.APNS_CERT_FILE
			keyFile: process.env.APNS_KEY_FILE
		mongo:
			dbname: process.env.MONGO_DBNAME || "xebia-mobile-backend"
			hostname: process.env.MONGO_HOSTNAME || "localhost"
			port: process.env.MONGO_PORT || 27017
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
	apns: config.apns




