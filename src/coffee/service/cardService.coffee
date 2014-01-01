fs = require 'fs'
_ = require('underscore')._

cardsData = JSON.parse(fs.readFileSync("#{__dirname}/../data/cards.json", "utf-8"))

categoriesData =
		categories: _.chain(cardsData.cards).pluck("category").uniq(false, (category) -> category.id).value()

cards = () ->
	cardsData

categories = () ->
	categoriesData

module.exports =
	cards: cards,
	categories:categories