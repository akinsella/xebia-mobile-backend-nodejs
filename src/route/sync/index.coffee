util = require 'util'
async = require 'async'
moment = require "moment"
request = require "request"
OAuth = require 'oauth'
_ = require('underscore')._

config = require "../../conf/config"

utils = require '../../lib/utils'
Cache = require '../../lib/cache'
db = require "../../db"
syncWordpressTask = require '../../task/syncWordpress'
syncWordpressPostsTask = require '../../task/syncWordpressPosts'

syncWordpress = (req, res) ->
	syncWordpressTask.synchronize()
	res.send 200, "Started sync for wordpress data"

syncWordpressPosts = (req, res) ->
	syncWordpressPostsTask.synchronize()
	res.send 200, "Started sync for wordpress posts"


module.exports =
	syncWordpress: syncWordpress
	syncWordpressPosts: syncWordpressPosts
