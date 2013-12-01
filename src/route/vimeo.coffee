util = require 'util'
async = require 'async'
request = require 'request'
OAuth = require 'oauth'
_ = require('underscore')._

Cache = require '../lib/cache'
utils = require '../lib/utils'
Video = require '../model/video'

videos = (req, res) ->
	Video.find({}).sort("-uploadDate").exec (err, videos) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }
		else
			videos = videos.map (video) ->
				video = video.toObject()
				delete video._id
				delete video.__v
				video.thumbnails.forEach (thumbnail) -> delete thumbnail._id
				video
			res.json videos

video = (req, res) ->
	videoId = req.params.id
	Video.findOne { id: videoId }, (err, video) ->
		if err
			res.json 500, { message: "Server error: #{err.message}" }

		else if !video
			res.json 404, "Not Found"
		else
			video = video.toObject()
			delete video._id
			delete video.__v
			video.thumbnails.forEach (thumbnail) -> delete thumbnail._id
			res.json video


module.exports =
	auth: auth
	callback: callback
	videos: videos
	video: video
