##################################################################################
# Imports
##################################################################################

logger = require 'winston'
_ = require('underscore')._
async = require 'async'
request = require 'request'
url = require 'url'
moment = require 'moment-timezone'


cache = require '../../../lib/cache'
utils = require '../../../lib/utils'
speakers = require './speakers'


##################################################################################
# Prototype extensions
##################################################################################

if !Array.prototype.last
	Array.prototype.last = () ->
		this[this.length - 1]

if !String.prototype.removeLastSlash
	String.prototype.removeLastSlash = () ->
		if this[this.length - 1] == '/'
			this.substring(0, this.length - 1)
		else
			this



##################################################################################
# Constants
##################################################################################

eventId = 16
baseUrl = "http://cfp.devoxx.co.uk/api/conferences/DevoxxUK2015"
userAgent =	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.55.3 (KHTML, like Gecko) Version/5.1.3 Safari/534.53.10"



##################################################################################
# Schedules
##################################################################################

schedules = (req, res) ->
	fetchSchedules (err, schedules) ->
		res.json schedules unless err
		res.send 500, err.message if err



fetchSchedules = (callback) ->
	schedulesCacheKey = "conference-#{eventId}-schedules"

	cache.get schedulesCacheKey, (err, cachedSchedules) ->
		headers = { "Accept-language": "fr-FR", "User-Agent": userAgent }
		if !err && cachedSchedules && cachedSchedules.etag
			headers["If-None-Match"] = cachedSchedules.etag

		schedulesURL = "#{baseUrl}/schedules"
		logger.info("Fetching info for schedules with url: #{schedulesURL}")
		request.get { url: schedulesURL, json: true, headers: headers }, (error, response, fetchedSchedules) ->
			if error
				callback(error)
			else
				if response.statusCode == 304
					logger.info("Schedules have not change, use those in cache ...")
					cachedSchedules.links.map (schedule) ->
						schedule.day = url.parse(schedule.href).pathname.removeLastSlash().split("/").last()
					async.map cachedSchedules.links, fetchSchedule, (err, schedules) ->
						callback(err, mapSchedules(schedules))
				else
					logger.info("Schedules has change or were never fetched, put it in cache ...")
					fetchedSchedules.etag = response.headers["etag"]
					cache.set schedulesCacheKey, fetchedSchedules, 3600, (err) ->
						if err
							callback(err)
						else
							fetchedSchedules.links.map (schedule) ->
								schedule.day = url.parse(schedule.href).pathname.removeLastSlash().split("/").last()
							async.map fetchedSchedules.links, fetchSchedule, (err, schedules) ->
								callback(err, mapSchedules(schedules))



mapSchedules = (schedules) ->
	if !schedules
		schedules
	else
		_.flatten(
			schedules.map (schedule) ->
				if !schedule
					schedule
				else
					schedule.slots
						.filter (slot) ->
							slot.talk || slot.break
						.map (slot) ->
							if slot.talk
								conferenceId: eventId
								fromTime: moment(slot.fromTimeMillis).tz("Europe/Paris").format("YYYY-MM-DD HH:mm:ss")
								id: slot.talk.id
								toTime: moment(slot.toTimeMillis).tz("Europe/Paris").format("YYYY-MM-DD HH:mm:ss")
								presentation:
									id: slot.talk.id
									uri: ""
									title: slot.talk.title
								speakers:
									slot.talk.speakers.map (speaker) ->
										id: url.parse(speaker.link.href).pathname.removeLastSlash().split("/").last()
										uri: ""
										name: speaker.name
								partnerSlot: false
								note: ""
								roomId: slot.roomId
								room: slot.roomName
								roomCapacity: slot.roomCapacity
								kind: "Talk"
								type: slot.talk.talkType
								code: slot.slotId
								title: slot.talk.title
								language: slot.talk.lang
								track: slot.talk.track
								summary: slot.talk.summary
							else
								conferenceId: eventId
								fromTime: moment(slot.fromTimeMillis).tz("Europe/Paris").format("YYYY-MM-DD HH:mm:ss")
								id: slot.slotId
								toTime: moment(slot.toTimeMillis).tz("Europe/Paris").format("YYYY-MM-DD HH:mm:ss")
								presentation:
									uri: ""
									title: ""
								speakers:
									[]
								partnerSlot: false
								note: ""
								language: ""
								roomId: slot.roomId
								room: slot.roomName
								roomCapacity: slot.roomCapacity
								kind: "Break"
								type: slot.break.id
								code: slot.slotId
								title: slot.break.nameFR
								track: ""
		)


fetchSchedule = (schedule, callback) ->
	schedule.day = url.parse(schedule.href).pathname.removeLastSlash().split("/").last()
	scheduleCacheKey = "conference-#{eventId}-schedule-#{schedule.day}"

	cache.get scheduleCacheKey, (err, cachedSchedule) ->
		headers = { "Accept-language": "fr-FR", "User-Agent": userAgent }
		if !err && cachedSchedule && cachedSchedule.etag
			headers["If-None-Match"] = cachedSchedule.etag

		scheduleUrl = schedule.href

		logger.info("Fetching schedule for day '#{schedule.day}' with url: #{scheduleUrl}")
		request.get { url: scheduleUrl, json: true, headers: headers }, (error, response, fetchedSchedule) ->
			if error
				callback(error)
			else
				if response.statusCode == 304
					logger.info("Schedule for day '#{schedule.day}' has not change, use the one in cache ...")
					callback(undefined, cachedSchedule)
				else
					logger.info("Schedule for day '#{schedule.day}' has change or was never fetched, put it in cache ...")
					fetchedSchedule.etag = response.headers["etag"]
					cache.set scheduleCacheKey, fetchedSchedule, 3600, (err) ->
						callback(err, fetchedSchedule)

module.exports =
	schedules: schedules
	fetchSchedules: fetchSchedules