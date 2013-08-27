config = require '../conf/config'
mongoose = require 'mongoose'
pureautoinc  = require 'mongoose-pureautoinc'

options =
  db: { native_parser: false },
  server: { poolSize: 5 },
  user: config.mongo.username,
  pass: config.mongo.password

url = "mongodb://#{config.mongo.hostname}:#{config.mongo.port}/#{config.mongo.dbname}"
mongoose.connect url, options


client = mongoose.connection
client.on 'error', console.error.bind(console, 'connection error:')
client.once 'open', () ->
	console.log "Connected to MongoBD on url: #{url}"

pureautoinc.init client

module.exports =
	client: client
	Schema: mongoose.Schema
