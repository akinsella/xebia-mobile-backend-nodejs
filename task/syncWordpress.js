// Generated by CoffeeScript 1.6.3
var News, async, config, db, moment, processWordpressRecentBlogPosts, request, synchronize, synchronizeWordpressNews, utils, _;

utils = require('../lib/utils');

async = require('async');

_ = require('underscore')._;

News = require("../model/news");

db = require("../db");

moment = require("moment");

config = require("../conf/config");

request = require("request");

synchronize = function() {
  var callback;
  callback = function(err, news) {
    if (err) {
      return console.log("Wordpress Synchronization ended with error: " + err.message + " - Error: " + err);
    } else {
      return console.log("Wordpress Synchronization ended with success ! (" + news.length + " blog posts synchronized) ");
    }
  };
  if (config.feature.stopWatch) {
    callback = utils.stopWatchCallbak(callback);
  }
  console.log("Start synchronizing Wordpress blog post entries ...");
  return processWordpressRecentBlogPosts(callback);
};

processWordpressRecentBlogPosts = function(callback) {
  return request.get({
    url: "http://blog.xebia.fr/wp-json-api/get_recent_posts?count=50",
    json: true
  }, function(error, data, response) {
    return async.map(response.posts, synchronizeWordpressNews, callback);
  });
};

synchronizeWordpressNews = function(post, callback) {
  return News.findOne({
    type: 'wordpress',
    typeId: post.id
  }, function(err, news) {
    var newsEntry;
    if (err) {
      return callback(err);
    } else if (!news) {
      newsEntry = new News({
        content: post.excerpt,
        draft: false,
        imageUrl: void 0,
        publicationDate: post.date,
        targetUrl: post.url,
        title: post.titlePlain,
        type: "wordpress",
        typeId: post.id
      });
      return newsEntry.save(function(err) {
        return callback(err, newsEntry);
      });
    } else {
      return callback(err, void 0);
    }
  });
};

module.exports = {
  synchronize: synchronize
};

/*
//@ sourceMappingURL=syncWordpress.map
*/
