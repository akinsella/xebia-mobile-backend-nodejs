utils = require '../lib/utils'
_ = require('underscore')._
OAuth = require 'oauth'
util = require 'util'
Cache = require '../lib/cache'
async = require 'async'
request = require 'request'
Video = require '../model/video'

apiHost = 'http://vimeo.com/api/rest/v2'

# To be refactored
processRequestOAuth = (req, res, url, oauth, credentials, transform) ->
#	res.setHeader('Cache-Control', 'private, max-age=300');
	options =
		req: req,
		res: res,
		url: url,
		cacheKey: utils.getCacheKey(req),
		forceNoCache: utils.getIfUseCache(req),
		cacheTimeout: 60 * 5,
		callback: utils.responseData,
		transform: transform,
		oauth: oauth,
		credentials: credentials

	utils.processRequest options


# To be refactored
processRequest = (req, res, url, transform) ->

	options = utils.buildOptions req, res, url, 5 * 60, transform
	utils.processRequest options


oauth = new OAuth.OAuth(
	'https://vimeo.com/oauth/request_token',
	'https://vimeo.com/oauth/access_token',
	process.env["VIMEO_OAUTH_CONSUMER_KEY"],
	process.env["VIMEO_OAUTH_CONSUMER_SECRET"],
	'1.0',
	process.env["VIMEO_OAUTH_CALLBACK"],
	'HMAC-SHA1'
)

auth = (req, res) ->
	oauth.getOAuthRequestToken( (error, oauthToken, oauthTokenSecret, results) ->
		if (error)
			console.error "login error %s", error
			utils.responseData 500, "Error getting OAuth request token : " + util.inspect(error), undefined, {req: req, res: res}
		else
			req.session = {} unless req.session
			req.session.oauthRequestToken = oauthToken
			req.session.oauthRequestTokenSecret = oauthTokenSecret

			return res.redirect("http://vimeo.com/oauth/authorize?oauth_token=#{req.session.oauthRequestToken}&permission=read")
	)

callback = (req, res) ->
	oauthToken = req.session.oauthRequestToken
	oauthTokenSecret = req.session.oauthRequestTokenSecret
	delete req.session.oauthRequestToken
	delete req.session.oauthRequestTokenSecret
	oauth.getOAuthAccessToken(
		oauthToken,
		oauthTokenSecret,
		req.query.oauth_verifier,
		(err, oauthAccessToken, oauthAccessTokenSecret, results) ->
			if err
				utils.responseData 500, "Error getting OAuth request token : " + util.inspect(err), undefined, {req: req, res: res}
			else
				Cache.set('vimeo.crendentials', { accessToken: oauthAccessToken, accessTokenSecret: oauthAccessTokenSecret },  -1,  (err) ->
					if err
						utils.responseData 500, "Error getting OAuth request token : " + util.inspect(err), undefined, {req: req, res: res}
					else
						res.redirect("/");
						console.info "Redirected to '/'"
				)


	)

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
	auth: auth
	callback: callback
	videos: videos
	video: video
	videoUrls: videoUrls
