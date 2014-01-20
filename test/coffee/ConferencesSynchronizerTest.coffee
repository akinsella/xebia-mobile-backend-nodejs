ConferencesSynchronizer = require "../task/ConferencesSynchronizer"
Conference = require '../model/conference'
Q = require 'q'
util = require 'util'
sinon = require 'sinon'
fs = require 'fs'
should = require 'should'
mocha = require 'mocha'

describe "Conferences Synchronizer", ->

	before (done) ->
		conferences = fs.readFileSync("#{__dirname}/data/conferences.json", "UTF-8")
		sinon.stub(fs, 'readFile').yields(null, conferences)
		done()

	after (done) ->
		fs.readFile.restore()
		done()


	it "it should synchronize Conferences", (done) ->
		Q.nfcall(Conference.remove.bind(Conference), {})
			.then () ->
				synchronizer = new ConferencesSynchronizer()
				Q.nfcall(synchronizer.synchronize)
			.then (conferenceIds) ->
				console.log("Saved #{conferenceIds.length} conferences")
				conferenceIds.length.should.greaterThan 0
				done()
			.fail (err) ->
				throw err
			.done()