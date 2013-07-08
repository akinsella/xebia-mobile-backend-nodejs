utils = require '../lib/utils'
_ = require('underscore')._
fs = require 'fs'

cardsData = JSON.parse(fs.readFileSync("#{__dirname}/../data/cards.json", "utf-8"))

cards = () ->
	cardsData

module.exports =
	cards: cards