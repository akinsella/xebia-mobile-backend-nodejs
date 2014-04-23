##################################################################################
# Imports
##################################################################################

logger = require 'winston'
_ = require('underscore')._
async = require 'async'
request = require 'request'
Q = require 'q'

cache = require '../../../lib/cache'
utils = require '../../../lib/utils'



##################################################################################
# Constants
##################################################################################

eventId = 11
speakersURL = "http://www.mix-it.fr/api/members/speakers"
talksURL = "http://www.mix-it.fr/api/talks"
lightningTalksURL = "http://www.mix-it.fr/api/lightningtalks"
userAgent =	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.55.3 (KHTML, like Gecko) Version/5.1.3 Safari/534.53.10"



##################################################################################
# Speakers
##################################################################################

speakers = (req, res) ->
	Q.spread [
		Q.nfcall(fetchSpeakers),
		Q.nfcall(fetchTalks),
		Q.nfcall(fetchLightningTalks)
	], (fetchedSpeakers, fetchedTalks, fetchedLightningTalks) ->
		for talk in fetchedLightningTalks
			fetchedTalks.push talk

		fetchedSpeakers.forEach (fetchedSpeaker) ->
			filteredTalks = fetchedTalks.filter (fetchedTalk) ->
				_(fetchedTalk.speakers).some (speaker) ->
					speaker == fetchedSpeaker.id

			filteredTalks.forEach (talk) ->
				delete talk.speakers

			fetchedSpeaker.talks = filteredTalks

		res.json fetchedSpeakers
	.fail (err) ->
		logger.info "Error - Message: #{err}"
	.done()



fetchSpeakers = (callback) ->
	request.get { url: speakersURL, json: true }, (error, response, fetchedSpeakers) ->
		if error
			callback(error)
		else
			callback undefined, fetchedSpeakers.map (speaker) ->
				mapSpeaker(speaker)


fetchTalks = (callback) ->
	request.get { url: talksURL, json: true }, (error, response, fetchedTalks) ->
		if error
			callback(error)
		else
			callback undefined, fetchedTalks.map (talk) ->
				mapTalk(talk)


fetchLightningTalks = (callback) ->
	request.get { url: lightningTalksURL, json: true }, (error, response, fetchedTalks) ->
		if error
			callback(error)
		else
			callback undefined, fetchedTalks.map (talk) ->
				mapTalk(talk)


mapSpeaker = (speaker) ->
	if !speaker
		speaker
	else
		id: speaker.id
		conferenceId: eventId
		firstName: speaker.firstname
		lastName: speaker.lastname
		company: speaker.company
		bio: speaker.shortdesc
		imageURL: speaker.urlimage
		tweetHandle: ""
		lang: "fr"
		blog: ""

mapTalk = (talk) ->
	presentationId: talk.id
	presentationUri: "http://www.mix-it.fr/api/lightningtalks/#{talk.id}"
	track: "",
	event: eventId,
	title: talk.title
	speakers: talk.speakers

module.exports =
	speakers: speakers
	fetchSpeakers: fetchSpeakers