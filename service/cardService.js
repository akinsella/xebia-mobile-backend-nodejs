// Generated by CoffeeScript 1.6.3
var cards, cardsData, categories, categoriesData, fs, utils, _;

utils = require('../lib/utils');

_ = require('underscore')._;

fs = require('fs');

cardsData = JSON.parse(fs.readFileSync("" + __dirname + "/../data/cards.json", "utf-8"));

categoriesData = {
  categories: _.chain(cardsData.cards).pluck("category").uniq(false, function(category) {
    return category.id;
  }).value()
};

cards = function() {
  return cardsData;
};

categories = function() {
  return categoriesData;
};

module.exports = {
  cards: cards,
  categories: categories
};

/*
//@ sourceMappingURL=cardService.map
*/