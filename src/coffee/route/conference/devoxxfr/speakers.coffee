##################################################################################
# Imports
##################################################################################

logger = require 'winston'
_ = require('underscore')._
async = require 'async'
request = require 'request'


cache = require '../../../lib/cache'
utils = require '../../../lib/utils'



##################################################################################
# Constants
##################################################################################

eventId = 11
baseUrl = "http://cfp.devoxx.fr/api/conferences/devoxxFR2014"
userAgent =	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.55.3 (KHTML, like Gecko) Version/5.1.3 Safari/534.53.10"



##################################################################################
# Speakers
##################################################################################

speakers = (req, res) ->
	fetchSpeakers (err, speakers) ->
		res.json speakers unless err
		res.send 500, err.message if err


fetchSpeakers = (callback) ->
	speakersCacheKey = "conference-#{eventId}-speaker"

	cache.get speakersCacheKey, (err, cachedSpeakers) ->
		headers = { "Accept-language": "fr-FR", "User-Agent": userAgent }
		if !err && cachedSpeakers && cachedSpeakers.etag
			headers["If-None-Match"] = cachedSpeakers.etag

		speakersUrl = "#{baseUrl}/speakers"
		logger.info("Fetching info for speakers with url: #{speakersUrl}")
		request.get { url: speakersUrl, json: true, headers: headers }, (error, response, fetchedSpeakers) ->
			if error
				callback(err)
			else
				if response.statusCode == 304
					logger.info("Speakers have not change, use those in cache ...")
					async.map cachedSpeakers, fetchSpeaker, (err, speakers) ->
						callback(err, mapSpeakers(speakers))
				else
					logger.info("Speakers has change or were never fetched, put it in cache ...")
					fetchedSpeakers.etag = response.headers["etag"]
					cache.set speakersCacheKey, fetchedSpeakers, 3600, (err) ->
						if err
							callback(err)
						else
							async.map fetchedSpeakers, fetchSpeaker, (err, speakers) ->
								callback(err, mapSpeakers(speakers))



mapSpeakers = (speakers) ->
	if !speakers
		speakers
	else
		speakers.map (speaker) ->
			if !speaker
				speaker
			else
				id: speaker.uuid
				conferenceId: eventId
				talks: speaker.acceptedTalks.map (talk) ->
					presentationId: talk.id
					presentationUri: (_(talk.links).find (link) -> link.rel == "http://cfp.devoxx.fr/api/profile/talk").href
					title: talk.title
					event: talk.talkType
					track: talk.track
				firstName: speaker.firstName
				lastName: speaker.lastName
				company: speaker.company
				bio: speaker.bio
				imageURL: speaker.avatarURL
				tweetHandle: speaker.twitter
				lang: speaker.lang
				blog: speaker.blog



fetchSpeaker = (speaker, callback) ->
	speakerCacheKey = "conference-#{eventId}-speaker-#{speaker.uuid}"

	cache.get speakerCacheKey, (err, cachedSpeaker) ->
		headers = { "Accept-language": "fr-FR", "User-Agent": userAgent }
		if !err && cachedSpeaker && cachedSpeaker.etag
			headers["If-None-Match"] = cachedSpeaker.etag

		speakerUrl = speaker.links[0].href

		logger.info("Fetching speaker with uuid '#{speaker.uuid}' with url: #{speakerUrl}")
		request.get { url: speakerUrl, json: true, headers: headers }, (error, response, fetchedSpeaker) ->
			if error
				callback(error)
			else
				if response.statusCode == 304
					logger.info("Speaker with uuid: '#{speaker.uuid}' has not change, use the one in cache ...")
					callback(undefined, cachedSpeaker)
				else
					logger.info("Speaker with uuid: '#{speaker.uuid}' has change or was never fetched, put it in cache ...")
					fetchedSpeaker.etag = response.headers["etag"]
					cache.set speakerCacheKey, fetchedSpeaker, 3600, (err) ->
						callback(err, fetchedSpeaker)


module.exports =
	speakers: speakers
	fetchSpeakers: fetchSpeakers