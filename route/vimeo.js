// Generated by CoffeeScript 1.6.3
var Cache, OAuth, Video, async, request, util, utils, video, videos, _;

util = require('util');

async = require('async');

request = require('request');

OAuth = require('oauth');

_ = require('underscore')._;

Cache = require('../lib/cache');

utils = require('../lib/utils');

Video = require('../model/video');

videos = function(req, res) {
  return Video.find({}).sort("-uploadDate").exec(function(err, videos) {
    if (err) {
      return res.json(500, {
        message: "Server error: " + err.message
      });
    } else {
      videos = videos.map(function(video) {
        video = video.toObject();
        delete video._id;
        delete video.__v;
        video.thumbnails.forEach(function(thumbnail) {
          return delete thumbnail._id;
        });
        return video;
      });
      return res.json(videos);
    }
  });
};

video = function(req, res) {
  var videoId;
  videoId = req.params.id;
  return Video.findOne({
    id: videoId
  }, function(err, video) {
    if (err) {
      return res.json(500, {
        message: "Server error: " + err.message
      });
    } else if (!video) {
      return res.json(404, "Not Found");
    } else {
      video = video.toObject();
      delete video._id;
      delete video.__v;
      video.thumbnails.forEach(function(thumbnail) {
        return delete thumbnail._id;
      });
      return res.json(video);
    }
  });
};

module.exports = {
  videos: videos,
  video: video
};

/*
//@ sourceMappingURL=vimeo.map
*/
