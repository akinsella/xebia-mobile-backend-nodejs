DevoxxFrPresentationsSynchronizer = require "../task/devoxxfr/DevoxxFrPresentationsSynchronizer"
Presentation = require '../model/presentation'
Q = require 'q'
util = require 'util'
sinon = require 'sinon'
request = require 'request'
fs = require 'fs'
should = require 'should'
mocha = require 'mocha'

describe "DevoxxFr Presentations Synchronizer", ->

	before (done) ->
		presentations = JSON.parse(fs.readFileSync("#{__dirname}/data/devoxxfr/presentations.json", "UTF-8"))
		sinon.stub(request, 'get').yields(null, {statusCode: 200}, presentations)
		done()


	after (done) ->
		request.get.restore()
		done()

	it "it should synchronize Presentations  ", (done) ->
		Q.nfcall(Presentation.remove.bind(Presentation), {})
			.then () ->
				synchronizer = new DevoxxFrPresentationsSynchronizer(11)
				Q.nfcall(synchronizer.synchronize)
			.then (presentationIds) ->
				console.log("Saved #{presentationIds.length} presentations")
				presentationIds.length.should.greaterThan 0
				done()
			.fail (err) ->
				throw err
			.done()