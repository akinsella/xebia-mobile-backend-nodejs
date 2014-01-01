mongoose = require 'mongoose'
pureautoinc  = require 'mongoose-pureautoinc'

config = require '../conf/config'

options =
  db: { native_parser: false },
  server: { poolSize: 5 },
  user: config.mongo.username,
  pass: config.mongo.password

url = "mongodb://#{config.mongo.hostname}:#{config.mongo.port}/#{config.mongo.dbname}"
console.log("config: " + JSON.stringify(config))
console.log("config: " + JSON.stringify(config.mongo))
console.log("Mongo Url: #{url}")
mongoose.connect url, options


client = mongoose.connection
client.on 'error', console.error.bind(console, 'connection error:')
client.once 'open', () ->
	console.log "Connected to MongoBD on url: #{url}"

pureautoinc.init client

module.exports =
	client: client
	Schema: mongoose.Schema
