utils = require '../lib/utils'
_ = require('underscore')._
fs = require 'fs'

cardsData = JSON.parse(fs.readFileSync("#{__dirname}/../data/cards.json", "utf-8"))

cards = () ->
	cardsData

categories = () ->
	categories =
		categories: _.chain(cardsData.cards).pluck("category").uniq(false, (category) -> category.id).value()

module.exports =
	cards: cards,
	categories:categories