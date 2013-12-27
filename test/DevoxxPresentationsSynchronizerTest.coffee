DevoxxPresentationsSynchronizer = require "../src/task/devoxx/DevoxxPresentationsSynchronizer"

describe "Devoxx Presentations Synchronizer", ->
	it "it should synchronize data", (done) ->
		synchronizer = new DevoxxPresentationsSynchronizer(10)
		synchronizer.synchronize (err, results) ->
			results.length.should.greaterThan 0
			done()