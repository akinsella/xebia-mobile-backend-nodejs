utils = require '../lib/utils'
_ = require('underscore')._
Card = require '../service/card'

cards = (req, res) ->

	cards = Card.cards()
	utils.responseData 200, "", cards, {req: req, res: res}


module.exports =
	cards: cards