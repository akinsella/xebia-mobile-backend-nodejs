DevoxxFrScheduleEntriesSynchronizer = require "../task/devoxxfr/DevoxxFrScheduleEntriesSynchronizer"
ScheduleEntry = require '../model/scheduleEntry'
Q = require 'q'
util = require 'util'
sinon = require 'sinon'
request = require 'request'
fs = require 'fs'
should = require 'should'
mocha = require 'mocha'

describe "DevoxxFr ScheduleEntries Synchronizer", ->

	before (done) ->
		tracks = JSON.parse(fs.readFileSync("#{__dirname}/data/devoxxfr/schedule.json", "UTF-8"))
		sinon.stub(request, 'get').yields(null, {statusCode: 200}, tracks)
		done()

	after (done) ->
		request.get.restore()
		done()


	it "it should synchronize ScheduleEntries", (done) ->
		Q.nfcall(ScheduleEntry.remove.bind(ScheduleEntry), {})
			.then () ->
				synchronizer = new DevoxxFrScheduleEntriesSynchronizer(10)
				Q.nfcall(synchronizer.synchronize)
			.then (scheduleEntryIds) ->
				console.log("Saved #{scheduleEntryIds.length} scheduleEntries")
				scheduleEntryIds.length.should.greaterThan 0
				done()
			.fail (err) ->
				throw err
			.done()