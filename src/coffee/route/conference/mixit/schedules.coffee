##################################################################################
# Imports
##################################################################################

logger = require 'winston'
_ = require('underscore')._
async = require 'async'
request = require 'request'
url = require 'url'
moment = require 'moment-timezone'
Q = require 'q'



##################################################################################
# Constants
##################################################################################

eventId = 13
speakersURL = "http://www.mix-it.fr/api/members/speakers"
talksURL = "http://www.mix-it.fr/api/talks"
lightningTalksURL = "http://www.mix-it.fr/api/lightningtalks"
interestsURL = "http://www.mix-it.fr/api/interests"


##################################################################################
# Schedules
##################################################################################

schedules = (req, res) ->
	Q.spread [
		Q.nfcall(fetchTalks, talksURL)
		Q.nfcall(fetchTalks, lightningTalksURL)
		Q.nfcall(fetchSpeakers)
		Q.nfcall(fetchInterests)
	], (fetchedTalks, fetchedLightningTalks, fetchedSpeakers, fetchedInterests) ->
		for talk in fetchedLightningTalks
			fetchedTalks.push talk


		fetchedTalks.forEach (fetchedTalk) ->
			fetchedTalk.speakers = fetchedSpeakers.filter (fetchedSpeaker) ->
				_(fetchedTalk.speakers).some (speakerId) ->
					speakerId == fetchedSpeaker.id


			fetchedTalk.tags = fetchedInterests.filter (fetchedInterest) ->
				_(fetchedTalk.interests).some (interestId) ->
					interestId == fetchedInterest.id

			delete fetchedTalk.interests


		res.json fetchedTalks
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

fetchInterests = (callback) ->
	request.get { url: interestsURL, json: true }, (error, response, fetchedInterests) ->
		if error
			callback(error)
		else
			callback undefined, fetchedInterests.map (interest) ->
				mapInterest(interest)


mapTalk = (talk) ->
	if !talk
		talk
	else
		id: talk.id
		conferenceId: eventId
		fromTime: moment(talk.start).tz("Europe/Paris").format("YYYY-MM-DD HH:mm:ss")
		toTime: moment(talk.end).tz("Europe/Paris").format("YYYY-MM-DD HH:mm:ss")
		partnerSlot: false
		note: ""
		language: talk.language
		roomId: if talk.room then talk.room.toUpperCase().replace(/\ /g, "_") else ""
		room: talk.room ?= ""
		roomCapacity: 0
		kind: talk.format ?= ""
		type: talk.format ?= ""
		code: talk.id
		title: talk.title
		track: talk.track ?= "Mix-IT"
		experience: talk.level ?= ""
		speakers: talk.speakers
		interests: talk.interests

mapSpeaker = (speaker) ->
	id: speaker.id
	uri: "http://www.mix-it.fr/api/speakers/#{speaker.id}"
	name: "#{speaker.firstname} #{speaker.lastname}"


mapInterest = (interest) ->
	id: interest.id
	name: interest.name

module.exports =
	schedules: schedules
