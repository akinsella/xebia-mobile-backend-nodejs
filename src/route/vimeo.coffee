utils = require '../lib/utils'
_ = require('underscore')._
OAuth = require 'oauth'
util = require 'util'
Cache = require '../lib/cache'

apiHost = 'http://vimeo.com/api/rest/v2'

# To be refactored
processRequest = (req, res, url, oauth, credentials, transform) ->
	options =
		req: req,
		res: res,
		url: url,
		cacheKey: utils.getCacheKey(req),
		forceNoCache: utils.getIfUseCache(req),
		cacheTimeout: 60 * 60,
		callback: utils.responseData,
		transform: transform,
		oauth: oauth,
		credentials: credentials

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

	url = "#{apiHost}?method=vimeo.videos.getAll&user_id=xebia&sort=newest&page=1&per_page=50&summary_response=true&full_response=false&format=json"
	Cache.get('vimeo.crendentials', (err, credentials) ->
		if err
			utils.responseData 500, "Error getting OAuth request data : " + util.inspect(err), undefined, {req: req, res: res}
		else if (!credentials)
			utils.responseData 500, "Error No Credentials stored", undefined, {req: req, res: res}
		else
			processRequest req, res, url, oauth, credentials, (data, cb) ->
				_(data.videos.video).each((video) -> transformVideo(video) )
				cb(undefined, data)
	)

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
	auth: auth,
	callback: callback,
	videos: videos
