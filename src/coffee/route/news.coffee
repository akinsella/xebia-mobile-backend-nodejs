utils = require '../lib/utils'
News = require '../model/news'
_ = require('underscore')._
moment = require('moment')


# To be refactored
processRequest = (req, res, url, transform) ->

	options = utils.buildOptions req, res, url, 5 * 60, transform
	utils.processRequest options


listUnfiltered = (req, res) ->
	News.find({}).sort("-publicationDate").limit(100).exec (err, news) ->
		if err
			utils.responseData(500, "Could not find news - Error: #{err.message}", undefined, { req:req, res:res })
		else
			utils.responseData(200, undefined, news.map(mapNews), { req:req, res:res })

list = (req, res) ->
	News.find { draft: false }.sort("-publicationDate").limit(100).exec (err, news) ->
		if err
			utils.responseData(500, "Could not find news - Error: #{err.message}", undefined, { req:req, res:res })
		else
			utils.responseData(200, undefined, mapNews(news), { req:req, res:res })

findById = (req, res) ->
	News.findOne { id: req.params.id }, (err, news) ->
		if err
			utils.responseData(500, "Could not find news - Error: #{err.message}", undefined, { req:req, res:res })
		if !news
			utils.responseData(404, "Not Found", undefined, { req:req, res:res})
		else
			utils.responseData(200, undefined, news, { req:req, res:res})

removeById = (req, res) ->
	News.findOneAndRemove { id: req.params.id }, (err, news) ->
		if err
			utils.responseData(500, "Could not remove news - Error: #{err.message}", undefined, { req:req, res:res })
		if !news
			utils.responseData(404, "Not Found", undefined, { req:req, res:res})
		else
			utils.responseData(204, undefined, news, { req:req, res:res})

create = (req, res) ->
	news = new News(req.body)
	news.save (err) ->
		if (err)
			utils.responseData(500, "Could not save news", req.body, { req:req, res:res})
		else
			utils.responseData(201, "Created", news, { req:req, res:res})

mapNews = (news) ->
	id: news.id
	content: news.content
	createdAt: news.createdAt
	draft: news.draft
	imageUrl: news.imageUrl
	lastModified: news.lastModified
	publicationDate: news.publicationDate
	targetUrl: news.targetUrl
	title: news.title
	author: news.author
	type: news.type
	typeId: news.typeId
	metadata: news.metadata
	publicationDate: moment(news.publicationDate).format("YYYY-MM-DD HH:mm:ss")
	lastModified: moment(news.lastModified).format("YYYY-MM-DD HH:mm:ss")
	createdAt: moment(news.createdAt).format("YYYY-MM-DD HH:mm:ss")
	publicationDate: moment(news.publicationDate).format("YYYY-MM-DD HH:mm:ss")


module.exports =
	list : list,
	listUnfiltered: listUnfiltered,
	findById : findById,
	create : create,
	removeById : removeById
