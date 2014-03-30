DevoxxFrPresentationTypesSynchronizer = require "../task/devoxxfr/DevoxxFrPresentationTypesSynchronizer"
PresentationType = require '../model/presentationType'
Q = require 'q'
util = require 'util'
sinon = require 'sinon'
request = require 'request'
fs = require 'fs'
should = require 'should'
mocha = require 'mocha'

describe "DevoxxFr PresentationTypes Synchronizer", ->

	before (done) ->
		tracks = JSON.parse(fs.readFileSync("#{__dirname}/data/devoxxfr/presentationTypes.json", "UTF-8"))
		sinon.stub(request, 'get').yields(null, {statusCode: 200}, tracks)
		done()

	after (done) ->
		request.get.restore()
		done()


	it "it should synchronize PresentationTypes", (done) ->
		Q.nfcall(PresentationType.remove.bind(PresentationType), {})
			.then () ->
				synchronizer = new DevoxxFrPresentationTypesSynchronizer(11)
				Q.nfcall(synchronizer.synchronize)
			.then (presentationTypeIds) ->
				console.log("Saved #{presentationTypeIds.length} presentationTypes")
				presentationTypeIds.length.should.greaterThan 0
				done()
			.fail (err) ->
				throw err
			.done()