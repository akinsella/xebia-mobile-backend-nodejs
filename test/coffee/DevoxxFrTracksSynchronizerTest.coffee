DevoxxFrTracksSynchronizer = require "../task/devoxxfr/DevoxxFrTracksSynchronizer"
Track = require '../model/track'
Q = require 'q'
util = require 'util'
sinon = require 'sinon'
request = require 'request'
fs = require 'fs'
should = require 'should'
mocha = require 'mocha'

describe "DevoxxFr Tracks Synchronizer", ->

	before (done) ->
		tracks = JSON.parse(fs.readFileSync("#{__dirname}/data/devoxxfr/tracks.json", "UTF-8"))
		sinon.stub(request, 'get').yields(null, {statusCode: 200}, tracks)
		done()

	after (done) ->
		request.get.restore()
		done()

	it "it should synchronize Tracks", (done) ->
		Q.nfcall(Track.remove.bind(Track), {})
			.then () ->
				synchronizer = new DevoxxFrTracksSynchronizer(11)
				Q.nfcall(synchronizer.synchronize)
			.then (trackIds) ->
				console.log("Saved #{trackIds.length} tracks")
				trackIds.length.should.greaterThan 0
				done()
			.fail (err) ->
				throw err
			.done()