fs = require 'fs'
_ = require('underscore')._

config = require '../conf/config'
utils = require '../lib/utils'
cardService = require '../service/cardService'

cards = (req, res) ->
	res.charset = 'UTF-8'

	cards = cardService.cards()
	utils.responseData 200, "", cards, {req: req, res: res}

categories = (req, res) ->
	res.charset = 'UTF-8'

	if config.offlineMode
		res.send JSON.parse(fs.readFileSync("#{__dirname}/../data/offline/essentials_category.json", "utf-8"))
	else
		categories = cardService.categories()
		utils.responseData 200, "", categories, {req: req, res: res}

cardsByCategoryId = (req, res) ->
	res.charset = 'UTF-8'

	if config.offlineMode
		res.send JSON.parse(fs.readFileSync("#{__dirname}/../data/offline/essentials_category_architecture_design.json", "utf-8"))
	else
		categoryId = req.params.id

		category = _(cardService.categories().categories).find( (category) ->
			category.id == categoryId
		)

		cards = _(cardService.cards().cards).filter( (card) ->
			card.category.id == categoryId
		)

		data = {
			category: category
			cards: cards
		}

		utils.responseData 200, "", data, {req: req, res: res}

cardById = (req, res) ->
	res.charset = 'UTF-8'

	cardId = req.params.id
	cards = _(cardService.cards().cards).find( (card) ->
		card.id == cardId
	)

	utils.responseData 200, "", cards, {req: req, res: res}


module.exports =
	cards: cards,
	cardById: cardById,
	categories: categories,
	cardsByCategoryId: cardsByCategoryId