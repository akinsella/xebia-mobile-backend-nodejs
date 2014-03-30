DevoxxFrRoomsSynchronizer = require "../task/devoxxfr/DevoxxFrRoomsSynchronizer"
Room = require '../model/room'
Q = require 'q'
util = require 'util'
sinon = require 'sinon'
request = require 'request'
fs = require 'fs'
should = require 'should'
mocha = require 'mocha'

describe "DevoxxFr Rooms Synchronizer", ->

	before (done) ->
		tracks = JSON.parse(fs.readFileSync("#{__dirname}/data/devoxxfr/rooms.json", "UTF-8"))
		sinon.stub(request, 'get').yields(null, {statusCode: 200}, tracks)
		done()

	after (done) ->
		request.get.restore()
		done()


	it "it should synchronize Rooms", (done) ->
		Q.nfcall(Room.remove.bind(Room), {})
			.then () ->
				synchronizer = new DevoxxFrRoomsSynchronizer(11)
				Q.nfcall(synchronizer.synchronize)
			.then (roomIds) ->
				console.log("Saved #{roomIds.length} rooms")
				roomIds.length.should.greaterThan 0
				done()
			.fail (err) ->
				throw err
			.done()