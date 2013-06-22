utils = require '../lib/utils'
_ = require('underscore')._
OAuth = require 'oauth'
util = require 'util'
sys = require 'sys'
CacheEntry = require '../model/cacheEntry'

apiHost = 'http://vimeo.com/api/rest/v2'

# To be refactored
processRequest = (req, res, url, transform) ->
	options = utils.buildOptions req, res, url, 5 * 60, transform
	utils.processRequest options

oauth = new OAuth.OAuth(
	'https://vimeo.com/oauth/request_token',
	'https://vimeo.com/oauth/access_token',
	process.env["OAUTH_VIMEO_CONSUMER_KEY"],
	process.env["OAUTH_VIMEO_CONSUMER_SECRET"],
	'1.0',
	'http://localhost:9000/api/vimeo/auth/callback',
	'HMAC-SHA1'
)

auth = (req, res) ->
	oauth.getOAuthRequestToken( (error, oauthToken, oauthTokenSecret, results) ->
		if (error)
			console.error "login error %s", error
			utils.responseData 500, "Error getting OAuth request token : " + sys.inspect(error), undefined, {req: req, res: res}
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
				utils.responseData 500, "Error getting OAuth request token : " + sys.inspect(err), undefined, {req: req, res: res}
			else
				new CacheEntry(
					'key': 'vimeo.crendentials'
					'value': { accessToken: oauthAccessToken, accessTokenSecret: oauthAccessTokenSecret }
				).save( (err) ->
					if err
						utils.responseData 500, "Error getting OAuth request token : " + sys.inspect(err), undefined, {req: req, res: res}
					else
						res.redirect("/");
						console.info "Redirected to '/'"
				)


	)

videos = (req, res) ->

	CacheEntry.findOne({key: 'vimeo.crendentials'}, (err, entry) ->
		if err
			utils.responseData 500, "Error getting OAuth request data : " + sys.inspect(err), undefined, {req: req, res: res}
		else
			oauth.get(
				apiHost + '?method=vimeo.videos.getAll&user_id=xebia&sort=newest&page=1&per_page=50&summary_response=true&full_response=false&format=json',
				entry.accessToken,
				entry.accessTokenSecret,
				(err, data, resp) ->
					if (err)
						console.error err
						utils.responseData 500, "", undefined, {req: req, res: res}
					else
						console.log sys.inspect(data)
						utils.responseData 200, "", data, {req: req, res: res}
			)

	)


module.exports =
	auth: auth,
	callback: callback,
	videos: videos
