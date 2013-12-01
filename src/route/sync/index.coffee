util = require 'util'
async = require 'async'
moment = require "moment"
request = require "request"
OAuth = require 'oauth'
_ = require('underscore')._

Event = require "../../model/event"
Video = require "../../model/video"

config = require "../../conf/config"

utils = require '../../lib/utils'
Cache = require '../../lib/cache'
db = require "../../db"
syncWordpressTask = require '../../task/syncWordpress'
syncWordpressPostsTask = require '../../task/syncWordpressPosts'
syncWordpressNewsTask = require '../../task/syncWordpressNews'

syncEventBriteTask = require '../../task/syncEventBrite'
syncEventBriteNewsTask = require '../../task/syncEventBriteNews'

syncVimeoTask = require '../../task/syncVimeo'
syncVimeoNewsTask = require '../../task/syncVimeoNews'

syncTwitterNewsTask = require '../../task/syncTwitterNews'

syncWordpress = (req, res) ->
	syncWordpressTask.synchronize()
	res.send 200, "Started sync for wordpress data"

syncWordpressPosts = (req, res) ->
	syncWordpressPostsTask.synchronize()
	res.send 200, "Started sync for wordpress posts"

syncWordpressNews = (req, res) ->
	syncWordpressNewsTask.synchronize()
	res.send 200, "Started sync for wordpress news"

syncEventBrite = (req, res) ->
	syncEventBriteTask.synchronize()
	res.send 200, "Started sync for eventbrite"

syncEventBriteNews = (req, res) ->
	syncEventBriteNewsTask.synchronize()
	res.send 200, "Started sync for eventbrite news"

syncVimeo = (req, res) ->
	syncVimeoTask.synchronize()
	res.send 200, "Started sync for vimeo"

syncVimeoNews = (req, res) ->
	syncVimeoNewsTask.synchronize()
	res.send 200, "Started sync for vimeo news"

syncTwitterNews = (req, res) ->
	syncVimeoNewsTask.synchronize()
	res.send 200, "Started sync for twitter news"

removeEvents = (req, res) ->
	Event.remove {}, (err) ->
		if err
			res.send 500, "Server error. Error: #{err.message}"
		else
			res.send 204, "Removed Events"

removeVideos = (req, res) ->
	Video.remove {}, (err) ->
		if err
			res.send 500, "Server error. Error: #{err.message}"
		else
			res.send 204, "Removed Events"


module.exports =
	syncWordpress: syncWordpress
	syncWordpressPosts: syncWordpressPosts
	syncWordpressNews: syncWordpressNews
	syncVimeo: syncVimeo
	syncVimeoNews: syncVimeoNews
	syncEventBrite: syncEventBrite
	syncEventBriteNews: syncEventBriteNews
	syncTwitterNews: syncTwitterNews
	removeVideos: removeVideos
	removeEvents: removeEvents
