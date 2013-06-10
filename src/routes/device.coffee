utils = require '../lib/utils'
_ = require('underscore')._
apn = require 'apn'
Device = require "../model/device"

create = (req, res) ->

	device = new Device({
		udid: req.body.udid,
		token: req.body.token
	})

	device.save (err) ->
		if (err)
			utils.responseData(500, "Could not save device", req.body, { req:req, res:res})
		else
			utils.responseData(204, "Created", device, { req:req, res:res})
		return

list = (req, res) ->
	Device.find {}, (err, devices) ->
		utils.responseData(200, undefined, devices, { req:req, res:res })
		return

findById = (req, res) ->
	Device.findOne { id: req.params.id }, (err, device) ->
		if (device)
			utils.responseData(200, undefined, device, { req:req, res:res })
		else
			utils.responseData(404, "Not Found", undefined, { req:req, res:res })
		return

removeById = (req, res) ->
	Device.findOneAndRemove { id: req.params.id }, (err, device) ->
		if (device)
			utils.responseData(204, undefined, device, { req:req, res:res })
		else
			utils.responseData(404, "Not Found", undefined, { req:req, res:res })
		return

module.exports =
	create : create,
	list : list,
	findById : findById,
	create : create,
	removeById : removeById
