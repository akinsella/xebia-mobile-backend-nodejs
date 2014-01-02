fs = require 'fs'
util = require 'util'
http = require 'http'
recluster = require 'recluster'
logger = require 'winston'

cluster = recluster "#{__dirname}/web-app"
cluster.run()

fs.watchFile "package.json", (curr, prev) ->
	logger.info "Package.json changed, reloading cluster..."
	cluster.reload()

process.on "SIGUSR2", ->
	logger.info "Got SIGUSR2, reloading cluster..."
	cluster.reload()

logger.info "Spawned cluster, kill -s SIGUSR2 #{process.pid} to reload"

###

logger.info "Will monitor port #{port} for heartbeat"
hostname = process.env.APP_HOSTNAME
port = process.env.APP_HTTP_PORT
heartbeatInterval = Number(process.env.HEARTBEAT_INTERVAL or 10) * 1000
startupDelay = Number(process.env.HEARTBEAT_DELAY or 10) * 1000

setTimeout(() ->
	setInterval(() ->
		# disable timeout on response.
		request = http.get("http://#{hostname}:#{port}", (res) ->
			request.setTimeout 0
			if [200, 302].indexOf(res.statusCode) is -1
				reloadCluster "[heartbeat] : FAIL with code #{res.statusCode}"
			else
				logger.info "[heartbeat]:  OK [#{res.statusCode}]"
		).on("error", (err) ->
			reloadCluster " [heartbeat]:  FAIL with #{err.message}"
		)
		request.setTimeout 10000, ->

			# QZ: This is an agressive reload on first failure. Later, we may change it
			# to reload on n consecutive failures
			reloadCluster " [heartbeat]: FAIL with timeout "

	, heartbeatInterval)
, startupDelay)

###
