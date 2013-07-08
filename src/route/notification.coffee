utils = require '../lib/utils'
_ = require('underscore')._
apn = require 'apn'
Device = require "../model/device"
Notification = require "../model/notification"

apnConnection = new apn.Connection({ "gateway": "gateway.sandbox.push.apple.com" })

feedback = new apn.Feedback({ "batchFeedback": true, "interval": 300 })

feedback.on "feedback", (devices) ->
	_(devices).each (device) ->
		console.log "Received feedback for deletion on timestamp: #{device.time} for device with token #{device.token}"

		Device.findOneAndRemove { token: device.token }, (err) ->
			if (err)
				console.log "Could not remove device with token: #{device.token}."
			else
				console.log "Removed device with token: #{device.token}"

push = (req, res) ->
	# set default to one day - Global ??
	# agent.set('expires', '1d');

	Notification.findOne { id: req.params.id }, (err, notification) ->
		if err
			utils.responseData(500, "Error: #{err}", "{}", { req:req, res:res })
		else
			Device.find {}, (err, devices) ->
				if err
					utils.responseData(500, "Error: #{err}", "{}", { req:req, res:res })
				else
					_(devices).each (device) ->
						apnDevice = new apn.Device(device.token)
						apnNotification = new apn.Notification()

						apnNotification.expiry = Math.floor(Date.now() / 1000) + 3600
						apnNotification.payload = notification.message;

						apnConnection.pushNotification(apnNotification, apnDevice);

					utils.responseData(200, "Ok", "{}", { req:req, res:res })


list = (req, res) ->
	Notification.find {}, (err, notifications) ->
		utils.responseData(200, undefined, notifications, { req:req, res:res })
		return

findById = (req, res) ->
	Notification.findOne { id: req.params.id }, (err, notification) ->
		if (notification)
			utils.responseData(200, undefined, notification, { req:req, res:res })
		else
			utils.responseData(404, "Not Found", undefined, { req:req, res:res })
		return

removeById = (req, res) ->
	Notification.findOneAndRemove { id: req.params.id }, (err, notification) ->
		if (notification)
			utils.responseData(204, undefined, notification, { req:req, res:res })
		else
			utils.responseData(404, "Not Found", undefined, { req:req, res:res })
		return

create = (req, res) ->
	notification = new Notification(req.body)
	notification.save (err) ->
		if (err)
			utils.responseData(500, "Could not save notification", req.body, { req:req, res:res })
		else
			utils.responseData(201, "Created", notification, { req:req, res:res })
		return

module.exports =
	push : push,
	list : list,
	findById : findById,
	create : create,
	removeById : removeById
