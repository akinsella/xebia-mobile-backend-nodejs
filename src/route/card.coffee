utils = require '../lib/utils'
_ = require('underscore')._
cardService = require '../service/cardService'

cards = (req, res) ->
	res.charset = 'UTF-8'

	cards = cardService.cards()
	utils.responseData 200, "", cards, {req: req, res: res}

categories = (req, res) ->
	res.charset = 'UTF-8'

	categories = cardService.categories()
	utils.responseData 200, "", categories, {req: req, res: res}

cardsByCategoryId = (req, res) ->
	res.charset = 'UTF-8'

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