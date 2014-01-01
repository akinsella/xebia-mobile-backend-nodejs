fs = require "fs"
util = require "util"
http = require "http"
recluster = require "recluster"

cluster = recluster "#{__dirname}/api-app"
cluster.run()

fs.watchFile "package.json", (curr, prev) ->
	console.log "Package.json changed, reloading cluster..."
	cluster.reload()

process.on "SIGUSR2", ->
	console.log "Got SIGUSR2, reloading cluster..."
	cluster.reload()

console.log "Spawned cluster, kill -s SIGUSR2 #{process.pid} to reload"
