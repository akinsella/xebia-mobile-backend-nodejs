utils = require '../lib/utils'
_ = require('underscore')._
ApnAgent = require 'apnagent'
Device = require "../model/device"
Notification = require "../model/notification"

agent = new ApnAgent.Agent()
agent
	.set('cert file', "#{__dirname}/../certs/xebia-apns-cert.pem")
	.set('key file', "#{__dirname}/../certs/xebia-apns-key.pem")
	.enable('sandbox')
	.set('expires', '1d')
	.set('reconnect delay', '1s')
	.set('cache ttl', '30m')

# see error mitigation section
agent.on 'message:error', (err, msg) ->
	console.log("Got some error: #{err.message} - Message: #{msg}")


# connect needed to start message processing
agent.connect (err) ->
	if err
		throw err
	else
		console.log("Apn agent running ")

#feedback.on "feedback", (devices) ->
#	_(devices).each (device) ->
#		console.log "Received feedback for deletion on timestamp: #{device.time} for device with token #{device.token}"
#
#		Device.findOneAndRemove { token: device.token }, (err) ->
#			if (err)
#				console.log "Could not remove device with token: #{device.token}."
#			else
#				console.log "Removed device with token: #{device.token}"

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
						pushNotification(device, notification)

					utils.responseData(200, "Ok", "{}", { req:req, res:res })

list = (req, res) ->
	Notification.find {}, (err, notifications) ->
		if err
			utils.responseData(500, "Could not find notification - Error: #{err.message}", undefined, { req:req, res:res })
		else
			utils.responseData(200, undefined, notifications, { req:req, res:res })

findById = (req, res) ->
	Notification.findOne { id: req.params.id }, (err, notification) ->
		if err
			utils.responseData(500, "Could not find notification - Error: #{err.message}", undefined, { req:req, res:res })
		else if !notification
			utils.responseData(404, "Not Found", undefined, { req:req, res:res })
		else
			utils.responseData(200, undefined, notification, { req:req, res:res })

removeById = (req, res) ->
	Notification.findOneAndRemove { id: req.params.id }, (err, notification) ->
		if err
			utils.responseData(500, "Could not remove notification - Error: #{err.message}", undefined, { req:req, res:res })
		else if !notification
			utils.responseData(404, "Not Found", undefined, { req:req, res:res })
		else
			utils.responseData(204, undefined, notification, { req:req, res:res })

create = (req, res) ->
	notification = new Notification(req.body)
	notification.save (err) ->
		if err
			utils.responseData(500, "Could not save notification", req.body, { req:req, res:res })
		else
			utils.responseData(201, "Created", notification, { req:req, res:res })

mapNotification = (notification) ->
	id: notification.id
	message: notification.message

pushNotification = (device, notification) ->
	console.log("Try to log Message: '#{notification.message}' to device with token: '#{device.token}'");
	agent
		.createMessage()
		.device(device.token)
		.alert(notification.message)
		.send((err) ->
			if err
				console.log("Count not send message: '#{notification.message}' for device with token: #{device.token}")
			else
				console.log("Message sent")
		)


module.exports =
	push : push
	list : list
	findById : findById
	create : create
	removeById : removeById
