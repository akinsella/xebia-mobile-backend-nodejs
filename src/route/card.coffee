utils = require '../lib/utils'
_ = require('underscore')._
Card = require '../service/card'

cards = (req, res) ->

	cards = Card.cards()
	utils.responseData 200, "", cards, {req: req, res: res}

categories = (req, res) ->

	categories = Card.categories()
	utils.responseData 200, "", categories, {req: req, res: res}

cardsByCategoryId = (req, res) ->

	categoryId = req.params.id
	cards = _(Card.cards().cards).filter( (card) ->
		card.category == categoryId
	)
	utils.responseData 200, "", cards, {req: req, res: res}

cardById = (req, res) ->

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