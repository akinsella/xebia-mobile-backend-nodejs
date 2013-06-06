config = require '../conf/config'
redis = require 'redis'

redis.debug_mode = false

redisClient = redis.createClient(config.redisConfig.credentials.port, config.redisConfig.credentials.hostname);

if config.redisConfig.credentials.password
	redisClient.auth config.redisConfig.credentials.password, (err, res) ->
		console.log "Authenticating to redis!"

redisClient.on "error", (err) ->
	console.log "Error " + err

module.exports =
	client: redisClient
