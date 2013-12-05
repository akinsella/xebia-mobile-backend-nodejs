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

videoUrls = (req, res) ->
	videoId = req.params.id

	videoConfigUrl = "http://player.vimeo.com/v2/video/#{videoId}/config"
	console.log "Fetching url: #{videoConfigUrl}"
	request.get { url: videoConfigUrl, json: true }, (error, data, response) ->

		videoUrls = _(response.request.files.codecs.map (codec) ->
			for key, value of response.request.files[codec]
				value["type"] = key
				value["codec"] = codec
				value
		).flatten()

		for key, value of response.request.files.hls
			videoUrl =
				url: value
				type: key
				codec: "hls"
				height: 0
				width: 0
				bitrate: 0
				id: 0
			videoUrls.push videoUrl

		_(videoUrls).each (video) ->
			delete video.profile
			delete video.origin
			delete video.availability

		res.json videoUrls


module.exports =
	videos: videos
	video: video
	videoUrls: videoUrls
