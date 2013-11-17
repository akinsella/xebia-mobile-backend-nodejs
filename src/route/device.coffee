utils = require '../lib/utils'
_ = require('underscore')._
apn = require 'apn'
Device = require "../model/device"

# To be refactored

create = (req, res) ->
	device = new Device(
		udid: req.body.udid
		token: req.body.token
	)

	device.save (err) ->
		if (err)
			utils.responseData(500, "Could not save device", req.body, { req:req, res:res })
		else
			utils.responseData(201, "Created", mapDevice(device), { req:req, res:res })

register = (req, res) ->

	Device.findOne { udid: req.body.udid, token: req.body.token }, (err, device) ->

		if err
			utils.responseData(500, "Could not check device is already registered", undefined, { req:req, res:res })
		else if device
			utils.responseData(200, "Device is already registered", mapDevice(device), { req:req, res:res })
		else
			device = new Device(
				udid: req.body.udid
				token: req.body.token
			)

			device.save (err) ->
				if err
					utils.responseData(500, "Could not save device", req.body, { req:req, res:res })
				else
					utils.responseData(201, "Created", mapDevice(device), { req:req, res:res })

list = (req, res) ->
	Device.find {}, (err, devices) ->
		if err
			utils.responseData(500, "Could not get device list", undefined, { req:req, res:res })
		else
			utils.responseData(200, undefined, devices.map(mapDevice), { req:req, res:res })

findById = (req, res) ->
	Device.findOne { id: req.params.id }, (err, device) ->
		if err
			utils.responseData(500, "Could not get device", undefined, { req:req, res:res })
		else if (!device)
			utils.responseData(404, "Not Found", undefined, { req:req, res:res })
		else
			utils.responseData(200, undefined, mapDevice(device), { req:req, res:res })

removeById = (req, res) ->
	Device.findOneAndRemove { id: req.params.id }, (err, device) ->
		if (device)
			utils.responseData(204, undefined, mapDevice(device), { req:req, res:res })
		else
			utils.responseData(404, "Not Found", undefined, { req:req, res:res })

mapDevice = (device) ->
	id: device.id
	token: device.token
	udid: device.udid

module.exports =
	register : register
	list : list
	findById : findById
	create : create
	removeById : removeById
