utils = require '../lib/utils'
News = require '../model/news'
_ = require('underscore')._
moment = require('moment')


# To be refactored
processRequest = (req, res, url, transform) ->

	options = utils.buildOptions req, res, url, 5 * 60, transform
	utils.processRequest options

	return

listUnfiltered = (req, res) ->
	News.find {}, { sort: {"publicationDate": -1}}, (err, news) ->
		if (news)
			utils.responseData(200, undefined, news, { req:req, res:res })
		else
			utils.responseData(404, "Not Found", undefined, { req:req, res:res })

list = (req, res) ->
	News.find { draft: false }, null, { sort: {"publicationDate": -1}}, (err, news) ->

		news = _(news).map (newsEntry) ->
			id: newsEntry.id
			content: newsEntry.content
			createdAt: newsEntry.createdAt
			draft: newsEntry.draft
			imageUrl: newsEntry.imageUrl
			lastModified: newsEntry.lastModified
			publicationDate: newsEntry.publicationDate
			targetUrl: newsEntry.targetUrl
			title: newsEntry.title
			type: newsEntry.type

		_(news).each (newsEntry) ->
			newsEntry.publicationDate = moment(newsEntry.publicationDate).format("YYYY-MM-DD HH:mm:ss")
			newsEntry.lastModified = moment(newsEntry.lastModified).format("YYYY-MM-DD HH:mm:ss")
			newsEntry.createdAt = moment(newsEntry.createdAt).format("YYYY-MM-DD HH:mm:ss")
			newsEntry.publicationDate = moment(newsEntry.publicationDate).format("YYYY-MM-DD HH:mm:ss")
		if (news)
			utils.responseData(200, undefined, news, { req:req, res:res })
		else
			utils.responseData(404, "Not Found", undefined, { req:req, res:res })

findById = (req, res) ->
	News.findOne { id: req.params.id }, (err, news) ->
		if (news)
			utils.responseData(200, undefined, news, { req:req, res:res})
		else
			utils.responseData(404, "Not Found", undefined, { req:req, res:res})

removeById = (req, res) ->
	News.findOneAndRemove { id: req.params.id }, (err, news) ->
		if (news)
			utils.responseData(204, undefined, news, { req:req, res:res})
		else
			utils.responseData(404, "Not Found", undefined, { req:req, res:res})

create = (req, res) ->
	news = new News(req.body)
	news.save (err) ->
		if (err)
			utils.responseData(500, "Could not save news", req.body, { req:req, res:res})
		else
			utils.responseData(201, "Created", news, { req:req, res:res})

module.exports =
	list : list,
	listUnfiltered: listUnfiltered,
	findById : findById,
	create : create,
	removeById : removeById
