_ = require('underscore')._
logger = require 'winston'
ApnAgent = require 'apnagent'

config = require '../conf/config'
Device = require '../model/device'
Notification = require '../model/notification'


#################################################################################################
## db.devices.update({}, { $set : { active : true } }, { multi: true })
#################################################################################################

logger.info "Dirname: #{__dirname}"

if !config.apns.enabled
	logger.info "[APNS] Apns is disabled"
	agent = {}
	feedback = {}
else
	logger.info "[APNS] Apns is enabled"

	#################################################################################################
	### Agent
	#################################################################################################

#	if config.devMode
#		logger.info "[APNS] Configuring Mock agent (Dev mode enabled)"
#		agent = new ApnAgent.MockAgent()
#	else
#		logger.info "[APNS] Configuring Live agent (Dev mode disabled)"
#		agent = new ApnAgent.Agent()

	logger.info "[APNS] Configuring Live agent"
	agent = new ApnAgent.Agent()

	logger.info "[APNS] Cert file: '#{config.apns.certFile}'"
	logger.info "[APNS] Key file: '#{config.apns.keyFile}'"

	agent
		.set('cert file', config.apns.certFile)
		.set('key file', config.apns.keyFile)
		.set('expires', '1d')
		.set('reconnect delay', '1s')
		.set('cache ttl', '30m')

	if config.apns.devMode
		logger.info "[APNS] Apns sandbox mode"
		agent.enable 'sandbox'
	else
		logger.info "[APNS] Apns production mode !"

	# see error mitigation section
	agent.on "message:error", (err, msg) ->
		switch err.name

			# This error occurs when Apple reports an issue parsing the message.
			when "GatewayNotificationError"
				logger.info "[APNS][message:error][#{err.name}] Error code: '#{err.code}', message: '#{err.message}'"

				# The err.code is the number that Apple reports.
				# Example: 8 means the token supplied is invalid or not subscribed
				# to notifications for your application.
				if err.code == 8
					logger.info "[APNS][message:error][#{err.name}] Device with token '#{msg.device().toString()}'"

			# In production you should flag this token as invalid and not
			# send any futher messages to it until you confirm validity

			# This happens when apnagent has a problem encoding the message for transfer
			when "SerializationError"
				logger.info "[APNS][message:error][#{err.name}] Error code: '#{err.code}', Error message: '#{err.message}'"

			# unlikely, but could occur if trying to send over a dead socket
			when "GatewayMessageError"
				token = msg.device().toString()
				logger.info "[APNS][message:error][#{err.name}] Error code: '#{err.code}', Error message: '#{err.message}' for device with token '#{token}'}'"
				disableDeviceWithToken token, (error, numberAffected) ->
					if error
						logger.info "[APNS] Had an error when trying to disabled device with token '#{token}' - Error message: '#{error.message}'"
					else if numberAffected == 0
						logger.info "[APNS] Could not disabled active device with token '#{token}'"
					else
						logger.info "[APNS] Device token with token: '#{token}' was disabled due to error with name '#{err.name}' and code '#{err.code}'"
			else
				logger.info "[APNS][message:error][#{err.name}] Error code: '#{err.code}', Error message: '#{err.message}'"

	# connect needed to start message processing
	agent.connect (err) ->

		if err and err.name is "GatewayAuthorizationError"
			logger.info "[APNS] Authentication Error: #{err.message}"
			process.exit 1

		# handle any other err (not likely)
		else if err
			throw err
		else
			logger.info "[APNS] Apn agent running"


	#################################################################################################
	### Feedback
	#################################################################################################

	logger.info "[APNS][Feedback] Initializing APNS feeback"

#	if config.devMode
#		logger.info "[APNS][Feedback] Configuring Mock feedback (Dev mode enabled)"
#		feedback = new ApnAgent.MockFeedback()
#	else
#		logger.info "[APNS][Feedback] Configuring Live feedback (Dev mode disabled)"
#		feedback = new ApnAgent.Feedback()
	logger.info "[APNS][Feedback] Configuring Live feedback"
	feedback = new ApnAgent.Feedback()

	feedback
		.set('interval', '30s')
		.connect()
	feedback.set 'concurrency', 1

	feedback.use (device, timestamp, done) ->
		logger.info "[APNS][Feedback] Got a feedback for device with Id: '#{device.toString()}' and timestamp: '#{timestamp}' (#{moment(timestamp)})"

		token = device.toString()

		Device.findOne { token: token, active: true }, (err, device) ->
			if err
				logger.info "[APNS][Feedback] Had an error when trying to found active device with token : '#{token}' - Error message: #{err.message}"
				done()
			else if !device
				logger.info "[APNS][Feedback] Could not found active device with token : '#{token}'"
				done()
			else
				disableDeviceWithToken token, (error, numberAffected) ->
					if error
						logger.info "[APNS][Feedback] Had an error when trying to disabled device with token : '#{token}' - Error message: #{error.message}"
						done()
					else if numberAffected == 0
						logger.info "[APNS][Feedback] Could not disabled active device with token : '#{token}'"
						done()
					else
						logger.info "[APNS] Device token with token: '#{token}' was disabled due to error with name '#{err.name}' and code '#{err.code}'"
						done()

disableDeviceWithToken = (token, callback) ->
	Device.update { token: token, active: true }, { active: false }, (err, numberAffected, raw) ->
		callback err, numberAffected


pushToAll = (message, cb) ->
	if !config.apns.enabled
		logger.info "[APNS][DISABLED] Could not push notification with Message: '#{message}'"
	else
		logger.info "[APNS] Pushing message to all active devices: '#{message}'"
		Device.find { active: true }, (err, devices) ->
			if err
				cb(err)
			else
				devices.forEach (device) ->
					pushNotification device.token, message
				cb()


pushNotificationToAll = (notificationId, cb) ->
	# set default to one day - Global ??
	# agent.set('expires', '1d');

	Notification.findOne { id: notificationId }, (err, notification) ->
		if err
			cb(err)
		else
			Device.find { active: true }, (err, devices) ->
				if err
					cb(err)
				else
					devices.forEach (device) ->
						pushNotification(device.token, notification.message)
					cb()


pushNotification = (token, message) ->
	if !config.apns.enabled
		logger.info "[APNS][DISABLED] Message: '#{message}' to device with token '#{token}'"
	else
		logger.info "[APNS] Try to push message to device with token '#{token}': '#{message}'"
		agent
			.createMessage()
			.device(token)
			.alert(message)
			.send (err) ->
				if err
					logger.info "[APNS] Count not send message for device with token '#{token}': '#{message}'"
				else
					logger.info "[APNS] Message sent to device with token '#{token}': '#{message}'"

module.exports =
	pushToAll: pushToAll
	pushNotificationToAll: pushNotificationToAll
