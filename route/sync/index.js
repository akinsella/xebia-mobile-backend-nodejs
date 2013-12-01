// Generated by CoffeeScript 1.6.3
var Author, Cache, Category, DetailedPost, Event, OAuth, Post, Tag, Video, async, config, db, moment, removeBlogData, removeBlogPosts, removeEvents, removeVideos, request, syncEventBrite, syncEventBriteNews, syncEventBriteNewsTask, syncEventBriteTask, syncTwitterNews, syncTwitterNewsTask, syncVimeo, syncVimeoNews, syncVimeoNewsTask, syncVimeoTask, syncWordpress, syncWordpressNews, syncWordpressNewsTask, syncWordpressPosts, syncWordpressPostsTask, syncWordpressTask, util, utils, _;

util = require('util');

async = require('async');

moment = require("moment");

request = require("request");

OAuth = require('oauth');

_ = require('underscore')._;

Event = require("../../model/event");

Video = require("../../model/video");

Post = require("../../model/post");

DetailedPost = require("../../model/detailedPost");

Tag = require("../../model/tag");

Category = require("../../model/category");

Author = require("../../model/author");

config = require("../../conf/config");

utils = require('../../lib/utils');

Cache = require('../../lib/cache');

db = require("../../db");

syncWordpressTask = require('../../task/syncWordpress');

syncWordpressPostsTask = require('../../task/syncWordpressPosts');

syncWordpressNewsTask = require('../../task/syncWordpressNews');

syncEventBriteTask = require('../../task/syncEventBrite');

syncEventBriteNewsTask = require('../../task/syncEventBriteNews');

syncVimeoTask = require('../../task/syncVimeo');

syncVimeoNewsTask = require('../../task/syncVimeoNews');

syncTwitterNewsTask = require('../../task/syncTwitterNews');

syncWordpress = function(req, res) {
  syncWordpressTask.synchronize();
  return res.send(200, "Started sync for wordpress data");
};

syncWordpressPosts = function(req, res) {
  syncWordpressPostsTask.synchronize();
  return res.send(200, "Started sync for wordpress posts");
};

syncWordpressNews = function(req, res) {
  syncWordpressNewsTask.synchronize();
  return res.send(200, "Started sync for wordpress news");
};

syncEventBrite = function(req, res) {
  syncEventBriteTask.synchronize();
  return res.send(200, "Started sync for eventbrite");
};

syncEventBriteNews = function(req, res) {
  syncEventBriteNewsTask.synchronize();
  return res.send(200, "Started sync for eventbrite news");
};

syncVimeo = function(req, res) {
  syncVimeoTask.synchronize();
  return res.send(200, "Started sync for vimeo");
};

syncVimeoNews = function(req, res) {
  syncVimeoNewsTask.synchronize();
  return res.send(200, "Started sync for vimeo news");
};

syncTwitterNews = function(req, res) {
  syncVimeoNewsTask.synchronize();
  return res.send(200, "Started sync for twitter news");
};

removeBlogData = function(req, res) {
  return async.parallel([
    function(callback) {
      return Tag.remove({}, function(err) {
        return callback(err, 'posts');
      });
    }, function(callback) {
      return Category.remove({}, function(err) {
        return callback(err, 'category');
      });
    }, function(callback) {
      return Author.remove({}, function(err) {
        return callback(err, 'author');
      });
    }
  ], function(err, results) {
    if (err) {
      return res.send(500, "Server error. Error: " + err.message);
    } else {
      return res.send(204, "Removed data : '" + results + "'");
    }
  });
};

removeBlogPosts = function(req, res) {
  return async.parallel([
    function(callback) {
      return Post.remove({}, function(err) {
        return callback(err, 'posts');
      });
    }, function(callback) {
      return DetailedPost.remove({}, function(err) {
        return callback(err, 'detailedPosts');
      });
    }
  ], function(err, results) {
    if (err) {
      return res.send(500, "Server error. Error: " + err.message);
    } else {
      return res.send(204, "Removed data : '" + results + "'");
    }
  });
};

removeEvents = function(req, res) {
  return Event.remove({}, function(err) {
    if (err) {
      return res.send(500, "Server error. Error: " + err.message);
    } else {
      return res.send(204, "Removed events");
    }
  });
};

removeVideos = function(req, res) {
  return Video.remove({}, function(err) {
    if (err) {
      return res.send(500, "Server error. Error: " + err.message);
    } else {
      return res.send(204, "Removed videos");
    }
  });
};

module.exports = {
  syncWordpress: syncWordpress,
  syncWordpressPosts: syncWordpressPosts,
  syncWordpressNews: syncWordpressNews,
  syncVimeo: syncVimeo,
  syncVimeoNews: syncVimeoNews,
  syncEventBrite: syncEventBrite,
  syncEventBriteNews: syncEventBriteNews,
  syncTwitterNews: syncTwitterNews,
  removeVideos: removeVideos,
  removeEvents: removeEvents,
  removeBlogPosts: removeBlogPosts,
  removeBlogData: removeBlogData
};

/*
//@ sourceMappingURL=index.map
*/
