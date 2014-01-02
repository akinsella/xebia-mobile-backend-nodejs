fs = require 'fs'
util = require 'util'
http = require 'http'
recluster = require 'recluster'
logger = require 'winston'

cluster = recluster "#{__dirname}/api-app"
cluster.run()

fs.watchFile "package.json", (curr, prev) ->
	logger.info "Package.json changed, reloading cluster..."
	cluster.reload()

process.on "SIGUSR2", ->
	logger.info "Got SIGUSR2, reloading cluster..."
	cluster.reload()

logger.info "Spawned cluster, kill -s SIGUSR2 #{process.pid} to reload"
