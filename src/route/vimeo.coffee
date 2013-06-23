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

			return res.redirect("http://vimeo.com/oauth/authorize?oauth_token=" + req.session.oauthRequestToken + "&permission=read");
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
			processRequest req, res, url, oauth, credentials, (data) -> data
	)


module.exports =
	auth: auth,
	callback: callback,
	videos: videos
