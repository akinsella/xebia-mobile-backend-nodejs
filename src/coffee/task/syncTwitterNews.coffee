logger = require 'winston'
async = require 'async'
OAuth = require 'oauth'
request = require "request"
moment = require "moment"
_ = require('underscore')._

Cache = require '../lib/cache'
utils = require '../lib/utils'
db = require "../db"
News = require "../model/news"
config = require "../conf/config"

synchronize = () ->
	callback = (err, news) ->
		if err
			logger.info "Twitter Synchronization ended with error: #{err.message} - Error: #{err}"
		else
			logger.info "Twitter Synchronization ended with success ! (#{news.length} tweets synchronized)"

	if config.feature.stopWatch
		callback = utils.stopWatchCallbak callback

	logger.info "Start synchronizing Tweets entries ..."

	processTweets(callback)


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

processTweets = (callback) ->
	twitterUrl = "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=XebiaFR&contributor_details=false&include_entities=true&include_rts=true&exclude_replies=false&count=50&exclude_replies=false"
	logger.info "Twitter Url: #{twitterUrl}"

	Cache.get('twitter.credentials', (err, credentials) ->
		if err
			logger.info "No valid twitter credentials: #{err}"
		else if (credentials)
			oauth2.get twitterUrl, credentials.accessToken, (error, data, response) ->
				data = if data then JSON.parse(data) else data
				async.map data, synchronizeTweetNews, callback
		else
			oauth2.getOAuthAccessToken('', {'grant_type': 'client_credentials'}, (err, accessToken, refreshToken, results) ->
				credentials = { accessToken: accessToken }
				if err
					logger.info "Could not retrieve vimeo credentials"
				else
					Cache.set('twitter.credentials', credentials, -1, (err) ->
						if (err)
							logger.info "No stored twitter credentials"
						else
							oauth2.get twitterUrl, credentials.accessToken, (error, data, response) ->
								data = if data then JSON.parse(data) else data
								async.map data, synchronizeTweetNews, callback
					)
			)
	)


synchronizeTweetNews = (tweet, callback) ->
	News.findOne { type: 'twitter', typeId: tweet.id_str }, (err, news) ->
		if err
			callback err
		else if !news

			newsEntry = new News(
				content: tweet.text
				draft: false
				imageUrl: ""
				publicationDate: moment(tweet.created_at, "ddd MMM DD HH:mm:ss ZZZ YYYY").format("YYYY-MM-DD HH:mm:ss")
				targetUrl: tweet.url
				title: tweet.text
				author: tweet.user.name
				type: "twitter"
				typeId: tweet.id_str
				metadata: [
					{ key: "screenName", value: tweet.user.screen_name }
				]
			)

			newsEntry.save (err) ->
				callback err, newsEntry.typeId
		else
			callback err, news.id


module.exports =
	synchronize: synchronize
