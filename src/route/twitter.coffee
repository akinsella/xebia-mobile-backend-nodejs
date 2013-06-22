twitter = require 'ntwitter'
utils = require '../lib/utils'
cache = require '../lib/cache'
_ = require('underscore')._

twit = new twitter({
	consumer_key: process.env.TWITTER_OAUTH_CONSUMER_KEY,
	consumer_secret:  process.env.TWITTER_OAUTH_CONSUMER_SECRET,
	access_token_key:  process.env.TWITTER_OAUTH_ACCESS_TOKEN_KEY,
	access_token_secret: process.env.TWITTER_OAUTH_ACCESS_TOKEN_SECRET
})


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

	return



#app.get('/twitter/:user', function(req, res) {
stream_xebiafr = (req, res) ->

	callback = getParameterByName(req.url, 'callback')
	res.send(callback ? callback + "(" + JSON.stringify(xebiaFrTweets) + ");": JSON.stringify(xebiaFrTweets))

	return



user_timeline_authenticated = (req, res) ->
	user = req.params.user
	console.log "User: " + user
	callback = getParameterByName(req.url, 'callback')

	cache.get req.url, (err, data) ->
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

					cache.set(utils.getCacheKey(req), jsonData, 60 * 60)
					console.log "[" + req.url + "] Fetched Response from url: " + jsonData
					callback(200, "", jsonData, {  callback: callback, req: req, res: res })

	return


# To be refactored
processRequest = (req, res, url, transform) ->

	options = utils.buildOptions req, res, url, 5 * 60, transform
	utils.processRequest options

	return

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
	if tweet.entities
		for eKey, entities of tweet.entities
			indices = []
			_(entities).each((entity) ->
				_(entity.indices).each((indice)->
					indices.push({indice:indice})
				)
				entity.indices = indices
			)
	if tweet.user
		for tuKey of tweet.user
			if !(tuKey in tweetUserProps) then delete tweet.user[tuKey]
	if tweet.retweeted_status
		if tweet.retweeted_status.entities
			for eKey, entities of tweet.retweeted_status.entities
				indices = []
				_(entities).each((entity) ->
					_(entity.indices).each((indice)->
						indices.push({indice:indice})
					)
					entity.indices = indices
				)

		for rtKey of tweet.retweeted_status
			if !(rtKey in retweetedStatusProps) then delete tweet.retweeted_status[rtKey]
		if tweet.retweeted_status.user
			for rtuKey of tweet.retweeted_status.user
				if !(rtuKey in retweetedStatusUserProps) then delete tweet.retweeted_status.user[rtuKey]
	tweet


user_timeline = (req, res) ->

	user = req.params.user
	console.log "User: " + user
	twitterUrl = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=" + user + "&contributor_details=false&include_entities=true&include_rts=true&exclude_replies=false&count=50&exclude_replies=false"
	console.log "Twitter Url: " + twitterUrl

	processRequest req, res, twitterUrl, (data) ->
		_(data).each((tweet) ->
			shortenTweet(tweet)
		)
		data


module.exports =
	stream_xebiafr : stream_xebiafr,
	user_timeline_authenticated : user_timeline_authenticated,
	user_timeline : user_timeline