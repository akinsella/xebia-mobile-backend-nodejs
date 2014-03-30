DevoxxFrExperienceLevelsSynchronizer = require "../task/devoxxfr/DevoxxFrExperienceLevelsSynchronizer"
ExperienceLevel = require '../model/experienceLevel'
Q = require 'q'
util = require 'util'
sinon = require 'sinon'
request = require 'request'
fs = require 'fs'
should = require 'should'
mocha = require 'mocha'

describe "DevoxxFr ExperienceLevels Synchronizer", ->

	before (done) ->
		tracks = JSON.parse(fs.readFileSync("#{__dirname}/data/devoxxfr/experienceLevels.json", "UTF-8"))
		sinon.stub(request, 'get').yields(null, {statusCode: 200}, tracks)
		done()

	after (done) ->
		request.get.restore()
		done()


	it "it should synchronize ExperienceLevels", (done) ->
		Q.nfcall(ExperienceLevel.remove.bind(ExperienceLevel), {})
			.then () ->
				synchronizer = new DevoxxFrExperienceLevelsSynchronizer(11)
				Q.nfcall(synchronizer.synchronize)
			.then (experienceLevelIds) ->
				console.log("Saved #{experienceLevelIds.length} experienceLevels")
				experienceLevelIds.length.should.equal 0
				done()
			.fail (err) ->
				throw err
			.done()