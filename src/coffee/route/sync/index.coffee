util = require 'util'
async = require 'async'
moment = require "moment"
request = require "request"
OAuth = require 'oauth'
_ = require('underscore')._

Event = require "../../model/event"
Video = require "../../model/video"
Post = require "../../model/post"
DetailedPost = require "../../model/detailedPost"
Tag = require "../../model/tag"
Category = require "../../model/category"
Author = require "../../model/author"

config = require "../../conf/config"

utils = require '../../lib/utils'
Cache = require '../../lib/cache'
db = require "../../db"
syncWordpressTask = require '../../task/syncWordpress'
syncWordpressPostsTask = require '../../task/syncWordpressPosts'
syncWordpressPostsCoAuthorsTask = require '../../task/syncWordpressPostsCoAuthors'
syncWordpressNewsTask = require '../../task/syncWordpressNews'

syncEventBriteTask = require '../../task/syncEventBrite'
syncEventBriteNewsTask = require '../../task/syncEventBriteNews'

syncVimeoTask = require '../../task/syncVimeo'
syncVimeoNewsTask = require '../../task/syncVimeoNews'

syncTwitterNewsTask = require '../../task/syncTwitterNews'

syncDevoxxBelgiumTask = require '../../task/syncDevoxxBelgium'
syncDevoxxFranceTask = require '../../task/syncDevoxxFrance'

syncWordpress = (req, res) ->
	syncWordpressTask.synchronize()
	res.send 200, "Started sync for Wordpress data"

syncWordpressPosts = (req, res) ->
	syncWordpressPostsCoAuthorsTask.synchronize()
	res.send 200, "Started sync for Wordpress posts"

syncWordpressPostsCoAuthors = (req, res) ->
	syncWordpressPostsCoAuthorsTask.synchronize()
	res.send 200, "Started sync for Wordpress co-authors posts"

syncWordpressNews = (req, res) ->
	syncWordpressNewsTask.synchronize()
	res.send 200, "Started sync for Wordpress news"

syncEventBrite = (req, res) ->
	syncEventBriteTask.synchronize()
	res.send 200, "Started sync for EventBrite"

syncEventBriteNews = (req, res) ->
	syncEventBriteNewsTask.synchronize()
	res.send 200, "Started sync for EventBrite news"

syncVimeo = (req, res) ->
	syncVimeoTask.synchronize()
	res.send 200, "Started sync for Vimeo"

syncVimeoNews = (req, res) ->
	syncVimeoNewsTask.synchronize()
	res.send 200, "Started sync for Vimeo news"

syncTwitterNews = (req, res) ->
	syncVimeoNewsTask.synchronize()
	res.send 200, "Started sync for Twitter news"


syncDevoxx10 = (req, res) ->
	syncDevoxxBelgiumTask.synchronize(1, 2010)()
	res.send 200, "Started sync for Devoxx 2010 data"

syncDevoxx11 = (req, res) ->
	syncDevoxxBelgiumTask.synchronize(4, 2011)()
	res.send 200, "Started sync for Devoxx 2011 data"

syncDevoxx12 = (req, res) ->
	syncDevoxxBelgiumTask.synchronize(7, 2012)()
	res.send 200, "Started sync for Devoxx 2012 data"

syncDevoxx13 = (req, res) ->
	syncDevoxxBelgiumTask.synchronize(10, 2013)()
	res.send 200, "Started sync for Devoxx 2013 data"

syncDevoxx14 = (req, res) ->
	syncDevoxxFranceTask.synchronize(14, "devoxxbe", 2014)()
	res.send 200, "Started sync for Devoxx 2014 data"


syncDevoxxFR12 = (req, res) ->
	syncDevoxxBelgiumTask.synchronize(6, 2013)()
	res.send 200, "Started sync for Devoxx France 2012 data"
syncDevoxxFR13 = (req, res) ->
	syncDevoxxBelgiumTask.synchronize(8, 2013)()
	res.send 200, "Started sync for Devoxx France 2013 data"
syncDevoxxFR14 = (req, res) ->
	syncDevoxxFranceTask.synchronize(11, "devoxxfr", 2014)()
	res.send 200, "Started sync for Devoxx France 2014 data"
syncDevoxxFR15 = (req, res) ->
	syncDevoxxFranceTask.synchronize(15, "devoxxfr", 2015)()
	res.send 200, "Started sync for Devoxx France 2015 data"

syncDevoxxUK13 = (req, res) ->
	syncDevoxxBelgiumTask.synchronize(9, 2014)()
	res.send 200, "Started sync for Devoxx Uk 2013 data"
syncDevoxxUK14 = (req, res) ->
	syncDevoxxBelgiumTask.synchronize(12, 2014)()
	res.send 200, "Started sync for Devoxx Uk 2014 data"

syncMixIT14 = (req, res) ->
	syncDevoxxFranceTask.synchronize(13, "mixit", 2014)()
	res.send 200, "Started sync for Mix-IT 2014 data"


removeBlogData = (req, res) ->
	async.parallel [
		(callback) ->
			Tag.remove {}, (err) ->
				callback(err, 'posts')
	,
		(callback) ->
			Category.remove {}, (err) ->
				callback(err, 'category')
	,
		(callback) ->
			Author.remove {}, (err) ->
				callback(err, 'author')
	],
		(err, results) ->
			if err
				res.send 500, "Server error. Error: #{err.message}"
			else
				res.send 204, "Removed data : '#{results}'"


removeBlogPosts = (req, res) ->
	async.parallel [
		(callback) ->
			Post.remove {}, (err) ->
				callback(err, 'posts')
		,
		(callback) ->
			DetailedPost.remove {}, (err) ->
				callback(err, 'detailedPosts')
	],
	(err, results) ->
		if err
			res.send 500, "Server error. Error: #{err.message}"
		else
			res.send 204, "Removed data : '#{results}'"


removeEvents = (req, res) ->
	Event.remove {}, (err) ->
		if err
			res.send 500, "Server error. Error: #{err.message}"
		else
			res.send 204, "Removed events"


removeVideos = (req, res) ->
	Video.remove {}, (err) ->
		if err
			res.send 500, "Server error. Error: #{err.message}"
		else
			res.send 204, "Removed videos"


module.exports =
	syncWordpress: syncWordpress
	syncWordpressPosts: syncWordpressPosts
	syncWordpressPostsCoAuthors: syncWordpressPostsCoAuthors
	syncWordpressNews: syncWordpressNews
	syncVimeo: syncVimeo
	syncVimeoNews: syncVimeoNews
	syncEventBrite: syncEventBrite
	syncEventBriteNews: syncEventBriteNews
	syncTwitterNews: syncTwitterNews
	syncDevoxx10: syncDevoxx10
	syncDevoxx11: syncDevoxx11
	syncDevoxx12: syncDevoxx12
	syncDevoxx13: syncDevoxx13
	syncDevoxx14: syncDevoxx14
	syncDevoxxFR12: syncDevoxxFR12
	syncDevoxxFR13: syncDevoxxFR13
	syncDevoxxFR14: syncDevoxxFR14
	syncDevoxxFR15: syncDevoxxFR15
	syncDevoxxUK13: syncDevoxxUK13
	syncDevoxxUK14: syncDevoxxUK14
	syncMixIT: syncMixIT14
	removeVideos: removeVideos
	removeEvents: removeEvents
	removeBlogPosts: removeBlogPosts
	removeBlogData: removeBlogData
