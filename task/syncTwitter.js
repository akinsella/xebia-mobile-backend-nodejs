// Generated by CoffeeScript 1.6.3
var Cache, News, OAuth, OAuth2, async, config, db, moment, oauth2, processTweets, request, synchronize, synchronizeTweetNews, twitterConsumerKey, twitterConsumerSecret, utils, _;

utils = require('../lib/utils');

async = require('async');

_ = require('underscore')._;

News = require("../model/news");

db = require("../db");

moment = require("moment");

config = require("../conf/config");

request = require("request");

OAuth = require('oauth');

Cache = require('../lib/cache');

synchronize = function() {
  var callback;
  callback = function(err, news) {
    if (err) {
      return console.log("Twitter Synchronization ended with error: " + err.message + " - Error: " + err);
    } else {
      return console.log("Twitter Synchronization ended with success ! (" + news.length + " tweets synchronized)");
    }
  };
  if (config.feature.stopWatch) {
    callback = utils.stopWatchCallbak(callback);
  }
  console.log("Start synchronizing Tweets entries ...");
  return processTweets(callback);
};

OAuth2 = OAuth.OAuth2;

twitterConsumerKey = process.env["TWITTER_OAUTH_CONSUMER_KEY"];

twitterConsumerSecret = process.env["TWITTER_OAUTH_CONSUMER_SECRET"];

oauth2 = new OAuth2(twitterConsumerKey, twitterConsumerSecret, 'https://api.twitter.com/', null, 'oauth2/token', null);

oauth2.useAuthorizationHeaderforGET(true);

processTweets = function(callback) {
  var twitterUrl;
  twitterUrl = "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=XebiaFR&contributor_details=false&include_entities=true&include_rts=true&exclude_replies=false&count=50&exclude_replies=false";
  console.log("Twitter Url: " + twitterUrl);
  return Cache.get('twitter.credentials', function(err, credentials) {
    if (err) {
      return console.log("No valid twitter credentials: " + err);
    } else if (credentials) {
      return oauth2.get(twitterUrl, credentials.accessToken, function(error, data, response) {
        data = data ? JSON.parse(data) : data;
        return async.map(data, synchronizeTweetNews, callback);
      });
    } else {
      return oauth2.getOAuthAccessToken('', {
        'grant_type': 'client_credentials'
      }, function(err, accessToken, refreshToken, results) {
        credentials = {
          accessToken: accessToken
        };
        if (err) {
          return console.log("Could not retrieve vimeo credentials");
        } else {
          return Cache.set('twitter.credentials', credentials, -1, function(err) {
            if (err) {
              return console.log("No stored twitter credentials");
            } else {
              return oauth2.get(twitterUrl, credentials.accessToken, function(error, data, response) {
                data = data ? JSON.parse(data) : data;
                return async.map(data, synchronizeTweetNews, callback);
              });
            }
          });
        }
      });
    }
  });
};

synchronizeTweetNews = function(tweet, callback) {
  return News.findOne({
    type: 'twitter',
    typeId: tweet.id_str
  }, function(err, news) {
    var newsEntry;
    if (err) {
      return callback(err);
    } else if (!news) {
      newsEntry = new News({
        content: tweet.text,
        draft: false,
        imageUrl: "",
        publicationDate: moment(tweet.created_at, "ddd MMM DD HH:mm:ss ZZZ YYYY").format("YYYY-MM-DD HH:mm:ss"),
        targetUrl: tweet.url,
        title: tweet.text,
        author: tweet.user.name,
        type: "twitter",
        typeId: tweet.id_str,
        metadata: [
          {
            key: "screenName",
            value: tweet.user.screen_name
          }
        ]
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
//@ sourceMappingURL=syncTwitter.map
*/
