config = require '../conf/config'
mongoose = require 'mongoose'
pureautoinc  = require 'mongoose-pureautoinc'

options =
  db: { native_parser: true },
  server: { poolSize: 5 },
  user: config.mongoConfig.credentials.username,
  pass: config.mongoConfig.credentials.password

url = "mongodb://#{config.mongoConfig.credentials.host}:#{config.mongoConfig.port}/#{config.mongoConfig.credentials.name}"
mongoose.connect url, options


client = mongoose.connection
client.on 'error', console.error.bind(console, 'connection error:')
client.once 'open', () ->
	console.log "Connected to MongoBD on url: #{url}"

pureautoinc.init client

module.exports =
	client: client
	Schema: mongoose.Schema
