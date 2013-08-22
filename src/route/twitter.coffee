#twitter = require 'ntwitter'
utils = require '../lib/utils'
request = require 'request'
_ = require('underscore')._
OAuth = require 'oauth'
Cache = require '../lib/cache'
moment = require 'moment'

###
twit = new twitter({
	consumer_key: process.env["TWITTER_OAUTH_CONSUMER_KEY"],
	consumer_secret: process.env["TWITTER_OAUTH_CONSUMER_SECRET"],
	access_token_key: process.env["TWITTER_OAUTH_ACCESS_TOKEN_KEY"],
	access_token_secret: process.env["TWITTER_OAUTH_ACCESS_TOKEN_SECRET"]
})
###


OAuth2 = OAuth.OAuth2
twitterConsumerKey = process.env["TWITTER_OAUTH_CONSUMER_KEY"]
twitterConsumerSecret = process.env["TWITTER_OAUTH_CONSUMER_SECRET"]

oauth2 = new OAuth2(
	twitterConsumerKey,
	twitterConsumerSecret,
	'https://api.twitter.com/',
	null,
	'oauth2/token',
	null
)
oauth2.useAuthorizationHeaderforGET(true)

###
xebiaFrTweets = []

# twit.stream('statuses/filter', { track: ['XebiaFR'] }, function(stream) {
twit.stream 'user', { track: 'XebiaFr' }, (stream) ->
	stream.on 'data', (data) ->
		console.log data

		tweet = data

		xebiaFrTweets.splice(100) if xebiaFrTweets.length > 100

		xebiaFrTweets.unshift shortenTweet(tweet)

	stream.on 'end', (response) ->
		# Handle a disconnection
		console.log 'Twitter Stream Connection End: ' + response

	stream.on 'destroy', (response) ->
		# Handle a 'silent' disconnection from Twitter, no end/error event fired
		console.log 'Twitter Stream Connection destroyed: ' + response


#app.get('/twitter/:user', function(req, res) {
stream_xebiafr = (req, res) ->
	callback = getParameterByName(req.url, 'callback')
	res.send(callback ? callback + "(" + JSON.stringify(xebiaFrTweets) + ");": JSON.stringify(xebiaFrTweets))


user_timeline_authenticated = (req, res) ->
	user = req.params.user
	console.log "User: " + user
	callback = getParameterByName(req.url, 'callback')

	Cache.get req.url, (err, data) ->
		if !err && data
			console.log "[" + req.url + "] A reply is in cache key: '" + utils.getCacheKey(req) + "', returning immediatly the reply"
			utils.responseData(200, "", data, {  callback: callback, req: req, res: res })

		else
			console.log "[" + req.url + "] No cached reply found for key: '" + utils.getCacheKey(req) + "'"
			twit.getUserTimeline "screen_name=" + user + "&contributor_details=false&include_entities=true&include_rts=true&exclude_replies=false&count=50&exclude_replies=false",
			(error, data) ->
				if error
					errorMessage = err.name + ": " + err.message
					utils.responseData(500, errorMessage, undefined, { callback: callback, req: req, res: res })
				else
					tweets = data

					tweetsShortened = []

					_(tweets).each (tweet) ->
						tweetsShortened.push shortenTweet(tweet)

					jsonData = JSON.stringify(tweetsShortened)

					Cache.set(utils.getCacheKey(req), jsonData, 60 * 60)
					console.log "[" + req.url + "] Fetched Response from url: " + jsonData
					callback(200, "", jsonData, {  callback: callback, req: req, res: res })

###

# To be refactored
processRequest = (req, res, url, oauth, credentials, transform) ->
	options =
		req: req,
		res: res,
		url: url,
		cacheKey: utils.getCacheKey(req),
		forceNoCache: utils.getIfUseCache(req),
		cacheTimeout: 5 * 60,
		callback: utils.responseData,
		transform: transform,
		oauth2: oauth2,
		credentials: credentials

	utils.processRequest options

xebia_timeline = (req, res) ->
	twitterUrl = "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=XebiaFR&contributor_details=false&include_entities=true&include_rts=true&exclude_replies=false&count=50&exclude_replies=false"
	console.log "Twitter Url: #{twitterUrl}"

	Cache.get('twitter.credentials', (err, credentials) ->
		if err
			utils.responseData(500, "", err, { req: req, res: res })
		else if (credentials)
			fetchTwitterData(twitterUrl, credentials, req, res)
		else
			oauth2.getOAuthAccessToken('', {'grant_type': 'client_credentials'}, (err, accessToken, refreshToken, results) ->
				credentials = { accessToken: accessToken }
				if err
					utils.responseData(500, "", err, { req: req, res: res })
				else
					Cache.set('twitter.credentials', credentials, -1, (err) ->
						if (err)
							utils.responseData(500, "", err, { req: req, res: res })
						else
							fetchTwitterData(twitterUrl, credentials, req, res)
					)
			)
	)


fetchTwitterData = (twitterUrl, credentials, req, res) ->
	processRequest req, res, twitterUrl, oauth2, credentials, (data, cb) ->
		_(data).each((tweet) ->
			shortenTweet(tweet)
		)
		cb(undefined, data)


tweetProps = [
	"id", "id_str", "created_at", "text", "favorited", "retweeted", "retweet_count", "entities", "retweeted_status", "user"
]

tweetUserProps = [
	"id", "id_str", "screen_name", "name", "profile_image_url"
]

retweetedStatusProps = [
	"id", "id_str", "created_at", "text", "favorited", "retweeted", "retweet_count", "entities", "user"
]

retweetedStatusUserProps = [
	"id", "id_str", "screen_name", "name", "profile_image_url"
]

shortenTweet = (tweet) ->
	for tKey of tweet
		if !(tKey in tweetProps) then delete tweet[tKey]
	tweet.created_at = moment(tweet.created_at, "ddd MMM DD HH:mm:ss ZZZ YYYY").format("YYYY-MM-DD HH:mm:ss")
	if tweet.entities
		for eKey, entities of tweet.entities
			indices = []
			_(entities).each((entity) ->
				entity.indices = {start:entity.indices[0], end:entity.indices[1]}
			)
	if tweet.user
		for tuKey of tweet.user
			if !(tuKey in tweetUserProps) then delete tweet.user[tuKey]
	if tweet.retweeted_status
		tweet.retweeted_status.created_at = moment(tweet.retweeted_status.created_at, "ddd MMM DD HH:mm:ss ZZZ YYYY").format("YYYY-MM-DD HH:mm:ss")
		if tweet.retweeted_status.entities
			for eKey, entities of tweet.retweeted_status.entities
				indices = []
				_(entities).each((entity) ->
					entity.indices = {start:entity.indices[0], end:entity.indices[1]}
				)

		for rtKey of tweet.retweeted_status
			if !(rtKey in retweetedStatusProps) then delete tweet.retweeted_status[rtKey]
		if tweet.retweeted_status.user
			for rtuKey of tweet.retweeted_status.user
				if !(rtuKey in retweetedStatusUserProps) then delete tweet.retweeted_status.user[rtuKey]
	tweet


module.exports =
#	stream_xebiafr : stream_xebiafr,
#	user_timeline_authenticated : user_timeline_authenticated,
	xebia_timeline : xebia_timeline