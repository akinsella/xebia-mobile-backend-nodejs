DevoxxFrSpeakersSynchronizer = require "../task/devoxxfr/DevoxxFrSpeakersSynchronizer"
Speaker = require '../model/speaker'
Q = require 'q'
util = require 'util'
sinon = require 'sinon'
request = require 'request'
fs = require 'fs'
should = require 'should'
mocha = require 'mocha'

describe "DevoxxFr Speakers Synchronizer", ->

	before (done) ->
		tracks = JSON.parse(fs.readFileSync("#{__dirname}/data/devoxxfr/speakers.json", "UTF-8"))
		sinon.stub(request, 'get').yields(null, {statusCode: 200}, tracks)
		done()

	after (done) ->
		request.get.restore()
		done()

	it "it should synchronize Speakers", (done) ->
		Q.nfcall(Speaker.remove.bind(Speaker), {})
		.then () ->
				synchronizer = new DevoxxFrSpeakersSynchronizer(10)
				Q.nfcall(synchronizer.synchronize)
		.then (speakerIds) ->
				console.log("Saved #{speakerIds.length} rooms")
				speakerIds.length.should.greaterThan 0
				done()
		.fail (err) ->
				throw err
		.done()