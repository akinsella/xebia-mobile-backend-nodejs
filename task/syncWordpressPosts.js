// Generated by CoffeeScript 1.6.3
var Author, Category, DetailedPost, News, Post, Tag, apns, async, config, db, moment, processWordpressRecentBlogPosts, request, synchronize, synchronizeWordpressDetailedPost, synchronizeWordpressPost, utils, _;

async = require('async');

moment = require("moment");

_ = require('underscore')._;

request = require("request");

config = require("../conf/config");

utils = require('../lib/utils');

db = require("../db");

apns = require("../lib/apns");

News = require("../model/news");

Tag = require("../model/tag");

Category = require("../model/category");

Author = require("../model/author");

Post = require("../model/post");

DetailedPost = require("../model/detailedPost");

synchronize = function() {
  var callback;
  callback = function(err, results) {
    if (err) {
      return console.log("Wordpress Synchronization of blog posts ended with error: " + err.message + " - Error: " + err);
    } else {
      return console.log("Wordpress Synchronization of blog posts ended with success ! Post Ids: " + results);
    }
  };
  if (config.feature.stopWatch) {
    callback = utils.stopWatchCallbak(callback);
  }
  console.log("Start synchronizing Wordpress data ...");
  return processWordpressRecentBlogPosts(1, callback, []);
};

processWordpressRecentBlogPosts = function(page, callback, results) {
  console.log("Start synchronizing Wordpress blog posts for page: " + page + " ...");
  return request.get({
    url: "http://blog.xebia.fr/wp-json-api/get_recent_posts?count=25&page=" + page,
    json: true
  }, function(error, data, response) {
    return async.map(response.posts, synchronizeWordpressPost, function(err, postIds) {
      console.log("Synchronized " + results.length + " Wordpress posts for page: " + page + ". Post Ids: " + postIds);
      return async.map(postIds, synchronizeWordpressDetailedPost, function(err, detailedPostIds) {
        if (err) {
          console.log("Wordpress Synchronization ended with error: " + err.message + " - Error: " + err);
        } else {
          console.log("Wordpress Synchronization of blog posts ended with success ! Detailed Post Ids: " + detailedPostIds);
        }
        console.log("Page: " + page + ", pages: " + response.pages);
        if (page < response.pages) {
          results.push(detailedPostIds);
          return process.nextTick(function() {
            return processWordpressRecentBlogPosts(page + 1, callback, results);
          });
        } else {
          return callback(void 0, results);
        }
      });
    });
  });
};

synchronizeWordpressPost = function(post, callback) {
  console.log("Checking for post with id: '" + post.id + "'");
  return Post.findOne({
    id: post.id
  }, function(err, foundPost) {
    var postEntry;
    if (err) {
      return callback(err);
    } else if (!foundPost) {
      postEntry = new Post(post);
      return postEntry.save(function(err) {
        callback(err, postEntry.id);
        if (!err) {
          return console.log("Saved detailed post with id: '" + postEntry.id + "'");
        }
      });
    } else {
      return callback(err, foundPost.id);
    }
  });
};

synchronizeWordpressDetailedPost = function(postId, callback) {
  console.log("Checking for detailed post with id: '" + postId + "'");
  return DetailedPost.findOne({
    id: postId
  }, function(err, foundDetailedPost) {
    if (err) {
      return callback(err);
    } else if (!foundDetailedPost) {
      return request.get({
        url: "http://blog.xebia.fr/wp-json-api/get_post?post_id=" + postId,
        json: true
      }, function(error, data, response) {
        var detailedPost, detailedPostEntry;
        if (err) {
          return callback(err);
        } else if (!response) {
          return callback(new Error("No detailed post with id: " + postId));
        } else {
          detailedPost = response.post;
          detailedPostEntry = new DetailedPost(detailedPost);
          return detailedPostEntry.save(function(err) {
            callback(err, detailedPostEntry.id);
            if (!err) {
              console.log("Saved detailed post with id: '" + detailedPostEntry.id + "'");
              return apns.pushToAll("New blog detailed post: " + detailedPostEntry.title, function() {
                return console.log("Pushed Notification for blog post with title: '" + detailedPostEntry.title + "'");
              });
            }
          });
        }
      });
    } else {
      return callback(err, foundDetailedPost.id);
    }
  });
};

module.exports = {
  synchronize: synchronize
};

/*
//@ sourceMappingURL=syncWordpressPosts.map
*/
