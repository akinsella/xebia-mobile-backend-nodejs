// Generated by CoffeeScript 1.6.3
var AccessToken, apn, utils, _;

utils = require('../lib/utils');

_ = require('underscore')._;

apn = require('apn');

AccessToken = require("../model/accessToken");

exports.find = function(token, done) {
  return AccessToken.find({
    token: token
  }, function(err, accessToken) {
    if (err) {
      return done(err, null);
    } else {
      return done(null, accessToken);
    }
  });
};

exports.save = function(token, userID, clientID, done) {
  var accessToken;
  accessToken = new AccessToken({
    userID: userID,
    clientID: clientID
  });
  return accessToken.save(function(err) {
    if (err) {
      return done(err);
    } else {
      return done(null);
    }
  });
};

/*
//@ sourceMappingURL=accessTokens.map
*/
