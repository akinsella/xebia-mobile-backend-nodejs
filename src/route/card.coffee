utils = require '../lib/utils'
_ = require('underscore')._
Card = require '../service/card'

cards = (req, res) ->
	res.charset = 'UTF-8'

	cards = Card.cards()
	utils.responseData 200, "", cards, {req: req, res: res}

categories = (req, res) ->
	res.charset = 'UTF-8'

	categories = Card.categories()
	utils.responseData 200, "", categories, {req: req, res: res}

cardsByCategoryId = (req, res) ->
	res.charset = 'UTF-8'

	categoryId = req.params.id

	category = _(Card.categories().categories).find( (category) ->
		category.id == categoryId
	)

	cards = _(Card.cards().cards).filter( (card) ->
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
	cards = _(Card.cards().cards).find( (card) ->
		card.id == cardId
	)

	utils.responseData 200, "", cards, {req: req, res: res}


module.exports =
	cards: cards,
	cardById: cardById,
	categories: categories,
	cardsByCategoryId: cardsByCategoryId