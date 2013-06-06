utils = require '../lib/utils'
News = require '../model/news'
_ = require('underscore')._


list = (req, res) ->
	News.find {}, (err, news) ->
		utils.responseData(200, undefined, news, { req:req, res:res})
		return

item = (req, res) ->
	News.findOne { id: req.params.id }, (err, news) ->
		if (news)
			utils.responseData(200, undefined, news, { req:req, res:res})
		else
			utils.responseData(404, "Not Found", undefined, { req:req, res:res})
		return

create = (req, res) ->
	news = new News(req.body)
	news.save (err) ->
		if (err)
			utils.responseData(500, "Could not save news", req.body, { req:req, res:res})
		else
			utils.responseData(204, "Created", news, { req:req, res:res})
		return

module.exports =
	list : list,
	item : item,
	create : create
