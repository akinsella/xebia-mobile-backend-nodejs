utils = require '../lib/utils'
async = require 'async'
_ = require('underscore')._
Video = require "../model/video"
db = require "../db"
moment = require "moment"
config = require "../conf/config"
request = require "request"
apns = require "../lib/apns"

OAuth = require 'oauth'
Cache = require '../lib/cache'

apiHost = 'http://vimeo.com/api/rest/v2'

oauth = new OAuth.OAuth(
	'https://vimeo.com/oauth/request_token',
	'https://vimeo.com/oauth/access_token',
	process.env["VIMEO_OAUTH_CONSUMER_KEY"],
	process.env["VIMEO_OAUTH_CONSUMER_SECRET"],
	'1.0',
	process.env["VIMEO_OAUTH_CALLBACK"],
	'HMAC-SHA1'
)

synchronize = () ->
	callback = (err, news) ->
		if err
			console.log "Vimeo Synchronization ended with error: #{err.message} - Error: #{err}"
		else
			console.log "Vimeo Synchronization ended with success ! (#{news.length} videos synchronized)"

	if config.feature.stopWatch
		callback = utils.stopWatchCallbak callback

	console.log "Start synchronizing Videos entries ..."

	processVideos(callback)


processVideos = (callback) ->
	url = "#{apiHost}?method=vimeo.videos.getAll&user_id=xebia&sort=newest&page=1&per_page=50&summary_response=true&full_response=false&format=json"
	Cache.get('vimeo.crendentials', (err, credentials) ->
		if err
			console.log "Error getting OAuth request data: #{err}"
		else if (!credentials)
			console.log 500, "Error No Credentials stored"
		else
		oauth.get url, credentials.accessToken, credentials.accessTokenSecret, (error, data, response) ->
			if error
				console.log 500, "Error No Credentials stored: #{error}"
			else
				data = if data then JSON.parse(data) else data
				async.map data.videos.video, synchronizeVideo, callback
	)


synchronizeVideo = (video, callback) ->
	Video.findOne { id: video.id }, (err, foundVideo) ->
		if err
			callback err
		else if !foundVideo
			video = transformVideo(video)
			videoEntry = new Video(video)

			videoEntry.save (err) ->
				callback err, videoEntry.id
				if !err
					apns.pushToAll "New video with id: #{videoEntry.id}", () ->
						console.log "Pushed notification for video with id: '#{videoEntry.id}'"
		else
			callback err, foundVideo.id


transformVideo = (video) ->
	video.embedPrivacy = video.embed_privacy
	delete video.embed_privacy
	video.isHd = Number(video.is_hd) > 0
	delete video.is_hd
	video.isTranscoding = Number(video.is_transcoding) > 0
	delete video.is_transcoding
	video.isWatchLater = Number(video.is_watchlater) > 0
	delete video.is_watchlater
	video.uploadDate = video.upload_date
	delete video.upload_date
	video.modifiedDate = video.modified_date
	delete video.modified_date
	video.likeCount = Number(video.number_of_likes)
	delete video.number_of_likes
	video.playCount = Number(video.number_of_plays)
	delete video.number_of_plays
	video.commentCount = Number(video.number_of_comments)
	delete video.number_of_comments
	video.thumbnails = video.thumbnails.thumbnail

	video.owner.profileUrl = video.owner.profileurl
	delete video.owner.profileurl
	video.owner.displayName = video.owner.display_name
	delete video.owner.display_name
	video.owner.isPlus = Number(video.owner.is_plus) > 0
	delete video.owner.is_plus
	video.owner.isPro = Number(video.owner.is_pro) > 0
	delete video.owner.is_pro
	video.owner.isStaff = Number(video.owner.is_staff) > 0
	delete video.owner.is_staff
	video.owner.realName = video.owner.realname
	delete video.owner.realname
	video.owner.videosUrl = video.owner.videosurl
	delete video.owner.videosurl

	_(video.thumbnails).each((thumbnail) ->
		thumbnail.width = Number(thumbnail.width)
		thumbnail.height = Number(thumbnail.height)
		thumbnail.url = thumbnail._content
		delete thumbnail._content
	)

	video


module.exports =
	synchronize: synchronize
