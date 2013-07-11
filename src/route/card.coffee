utils = require '../lib/utils'
_ = require('underscore')._
Card = require '../service/card'

cards = (req, res) ->

	cards = Card.cards()
	utils.responseData 200, "", cards, {req: req, res: res}

categories = (req, res) ->

	categories = Card.categories()
	utils.responseData 200, "", categories, {req: req, res: res}


module.exports =
	cards: cards,
	categories: categories