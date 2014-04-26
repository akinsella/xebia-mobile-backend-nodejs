##################################################################################
# Imports
##################################################################################

logger = require 'winston'
_ = require('underscore')._
async = require 'async'
request = require 'request'
Q = require 'q'



##################################################################################
# Constants
##################################################################################

eventId = 13
speakersURL = "http://www.mix-it.fr/api/members/speakers"
talksURL = "http://www.mix-it.fr/api/talks"
lightningTalksURL = "http://www.mix-it.fr/api/lightningtalks"



##################################################################################
# Speakers
##################################################################################

speakers = (req, res) ->
	Q.spread [
		Q.nfcall(fetchSpeakers)
		Q.nfcall(fetchTalks, talksURL)
		Q.nfcall(fetchTalks, lightningTalksURL)
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


fetchTalks = (talksURL, callback) ->
	request.get { url: talksURL, json: true }, (error, response, fetchedTalks) ->
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