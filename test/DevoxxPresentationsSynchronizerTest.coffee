DevoxxPresentationsSynchronizer = require "../src/task/devoxx/DevoxxPresentationsSynchronizer"
Presentation = require '../src/model/presentation.coffee'
Q = require 'q'
util = require 'util'
sinon = require 'sinon'
request = require 'request'
fs = require 'fs'

describe "Devoxx Presentations Synchronizer", ->

	before (done) ->
		presentations = JSON.parse(fs.readFileSync("#{__dirname}/../data/presentations.json", "UTF-8"))
		sinon.stub(request, 'get').yields(null, {statusCode: 200}, presentations)
		done()

	after (done) ->
		request.get.restore()
		done()

	it "it should synchronize data", (done) ->
		Q.nfcall(Presentation.remove.bind(Presentation), {})
			.then () ->
				synchronizer = new DevoxxPresentationsSynchronizer(10)
				Q.nfcall(synchronizer.synchronize)
			.then (presentationIds) ->
				console.log("Saved #{presentationIds.length} presentations")
				presentationIds.length.should.greaterThan 0
				done()
			.fail (err) ->
				throw err
			.done()