logger = require 'winston'
async = require 'async'
moment = require "moment"
request = require "request"
OAuth = require 'oauth'
_ = require('underscore')._

config = require "../conf/config"
utils = require '../lib/utils'
Cache = require '../lib/cache'
db = require "../db"
News = require "../model/news"

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
			logger.info "Vimeo Synchronization ended with error: #{err.message} - Error: #{err}"
		else
			logger.info "Vimeo Synchronization ended with success ! (#{news.length} videos synchronized)"

	if config.feature.stopWatch
		callback = utils.stopWatchCallbak callback

	logger.info "Start synchronizing Videos entries ..."

	processVideos(callback)


processVideos = (callback) ->
	url = "#{apiHost}?method=vimeo.videos.getAll&user_id=xebia&sort=newest&page=1&per_page=50&summary_response=true&full_response=false&format=json"
	Cache.get('vimeo.crendentials', (err, credentials) ->
		if err
			logger.info "Error getting OAuth request data: #{err}"
		else if (!credentials)
			logger.info 500, "Error No Credentials stored"
		else
		oauth.get url, credentials.accessToken, credentials.accessTokenSecret, (error, data, response) ->
			if error
				logger.info 500, "Error No Credentials stored: #{error}"
			else
				data = if data then JSON.parse(data) else data
				async.map data.videos.video, synchronizeVideoNews, callback
	)


synchronizeVideoNews = (video, callback) ->
	News.findOne { type: 'vimeo', typeId: video.id }, (err, news) ->
		if err
			callback err
		else if !news

			newsEntry = new News(
				content: video.title
				draft: false
				imageUrl: ""
				publicationDate: video.upload_date
				title: video.title
				author: video.owner.fullname
				type: "vimeo"
				typeId: video.id
			)

			newsEntry.save (err) ->
				callback err, news.typeId

		else
			callback err, news.typeId


module.exports =
	synchronize: synchronize
