underscore = require 'underscore'
_ = underscore._

if !config
	localConfig =
		hostname: 'localhost',
		port: 8000,
		appname: 'xebia-mobile-backend.helyx.org',
		uri: ['xebia-mobile-backend.cloudfoundry.com'],
		mongo:
			dbname: 'xebia-mobile-backend'
			hostname: 'localhost',
			port: 27017,
	#		username: 'xebia-mobile-backend'
	#		password: 'Password123'

	config = _.extend({}, localConfig)

module.exports =
	hostname: config.hostname,
	port: config.port,
	appname: config.appname,
	uri: config.uri,
	mongo: config.mongo




