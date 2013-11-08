// Generated by CoffeeScript 1.6.3
var Cache, OAuth, apiHost, async, auth, callback, oauth, processRequest, processRequestOAuth, request, transformVideo, util, utils, videoUrls, videos, _;

utils = require('../lib/utils');

_ = require('underscore')._;

OAuth = require('oauth');

util = require('util');

Cache = require('../lib/cache');

async = require('async');

request = require('request');

apiHost = 'http://vimeo.com/api/rest/v2';

processRequestOAuth = function(req, res, url, oauth, credentials, transform) {
  var options;
  options = {
    req: req,
    res: res,
    url: url,
    cacheKey: utils.getCacheKey(req),
    forceNoCache: utils.getIfUseCache(req),
    cacheTimeout: 60 * 5,
    callback: utils.responseData,
    transform: transform,
    oauth: oauth,
    credentials: credentials
  };
  return utils.processRequest(options);
};

processRequest = function(req, res, url, transform) {
  var options;
  options = utils.buildOptions(req, res, url, 5 * 60, transform);
  return utils.processRequest(options);
};

oauth = new OAuth.OAuth('https://vimeo.com/oauth/request_token', 'https://vimeo.com/oauth/access_token', process.env["VIMEO_OAUTH_CONSUMER_KEY"], process.env["VIMEO_OAUTH_CONSUMER_SECRET"], '1.0', process.env["VIMEO_OAUTH_CALLBACK"], 'HMAC-SHA1');

auth = function(req, res) {
  return oauth.getOAuthRequestToken(function(error, oauthToken, oauthTokenSecret, results) {
    if (error) {
      console.error("login error %s", error);
      return utils.responseData(500, "Error getting OAuth request token : " + util.inspect(error), void 0, {
        req: req,
        res: res
      });
    } else {
      if (!req.session) {
        req.session = {};
      }
      req.session.oauthRequestToken = oauthToken;
      req.session.oauthRequestTokenSecret = oauthTokenSecret;
      return res.redirect("http://vimeo.com/oauth/authorize?oauth_token=" + req.session.oauthRequestToken + "&permission=read");
    }
  });
};

callback = function(req, res) {
  var oauthToken, oauthTokenSecret;
  oauthToken = req.session.oauthRequestToken;
  oauthTokenSecret = req.session.oauthRequestTokenSecret;
  delete req.session.oauthRequestToken;
  delete req.session.oauthRequestTokenSecret;
  return oauth.getOAuthAccessToken(oauthToken, oauthTokenSecret, req.query.oauth_verifier, function(err, oauthAccessToken, oauthAccessTokenSecret, results) {
    if (err) {
      return utils.responseData(500, "Error getting OAuth request token : " + util.inspect(err), void 0, {
        req: req,
        res: res
      });
    } else {
      return Cache.set('vimeo.crendentials', {
        accessToken: oauthAccessToken,
        accessTokenSecret: oauthAccessTokenSecret
      }, -1, function(err) {
        if (err) {
          return utils.responseData(500, "Error getting OAuth request token : " + util.inspect(err), void 0, {
            req: req,
            res: res
          });
        } else {
          res.redirect("/");
          return console.info("Redirected to '/'");
        }
      });
    }
  });
};

videos = function(req, res) {
  var url;
  url = "" + apiHost + "?method=vimeo.videos.getAll&user_id=xebia&sort=newest&page=1&per_page=50&summary_response=true&full_response=false&format=json";
  return Cache.get('vimeo.crendentials', function(err, credentials) {
    if (err) {
      return utils.responseData(500, "Error getting OAuth request data : " + util.inspect(err), void 0, {
        req: req,
        res: res
      });
    } else if (!credentials) {
      return utils.responseData(500, "Error No Credentials stored", void 0, {
        req: req,
        res: res
      });
    } else {
      return processRequestOAuth(req, res, url, oauth, credentials, function(data, cb) {
        return async.map(data.videos.video, transformVideo, function(err, videos) {
          return cb(void 0, videos);
        });
      });
    }
  });
};

videoUrls = function(req, res) {
  var videoConfigUrl, videoId;
  videoId = req.params.id;
  videoConfigUrl = "http://player.vimeo.com/v2/video/" + videoId + "/config";
  console.log("Fetching url: " + videoConfigUrl);
  return request.get({
    url: videoConfigUrl,
    json: true
  }, function(error, data, response) {
    var key, value, videoUrl, _ref;
    videoUrls = _(response.request.files.codecs.map(function(codec) {
      var key, value, _ref, _results;
      _ref = response.request.files[codec];
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        value["type"] = key;
        value["codec"] = codec;
        _results.push(value);
      }
      return _results;
    })).flatten();
    _ref = response.request.files.hls;
    for (key in _ref) {
      value = _ref[key];
      videoUrl = {
        url: value,
        type: key,
        codec: "hls",
        height: 0,
        width: 0,
        bitrate: 0,
        id: 0
      };
      videoUrls.push(videoUrl);
    }
    _(videoUrls).each(function(video) {
      delete video.profile;
      delete video.origin;
      return delete video.availability;
    });
    return res.json(videoUrls);
  });
};

transformVideo = function(video, cb) {
  video.embedPrivacy = video.embed_privacy;
  delete video.embed_privacy;
  video.isHd = Number(video.is_hd) > 0;
  delete video.is_hd;
  video.isTranscoding = Number(video.is_transcoding) > 0;
  delete video.is_transcoding;
  video.isWatchLater = Number(video.is_watchlater) > 0;
  delete video.is_watchlater;
  video.uploadDate = video.upload_date;
  delete video.upload_date;
  video.modifiedDate = video.modified_date;
  delete video.modified_date;
  video.likeCount = Number(video.number_of_likes);
  delete video.number_of_likes;
  video.playCount = Number(video.number_of_plays);
  delete video.number_of_plays;
  video.commentCount = Number(video.number_of_comments);
  delete video.number_of_comments;
  video.thumbnails = video.thumbnails.thumbnail;
  video.owner.profileUrl = video.owner.profileurl;
  delete video.owner.profileurl;
  video.owner.displayName = video.owner.display_name;
  delete video.owner.display_name;
  video.owner.isPlus = Number(video.owner.is_plus) > 0;
  delete video.owner.is_plus;
  video.owner.isPro = Number(video.owner.is_pro) > 0;
  delete video.owner.is_pro;
  video.owner.isStaff = Number(video.owner.is_staff) > 0;
  delete video.owner.is_staff;
  video.owner.realName = video.owner.realname;
  delete video.owner.realname;
  video.owner.videosUrl = video.owner.videosurl;
  delete video.owner.videosurl;
  _(video.thumbnails).each(function(thumbnail) {
    thumbnail.width = Number(thumbnail.width);
    thumbnail.height = Number(thumbnail.height);
    thumbnail.url = thumbnail._content;
    return delete thumbnail._content;
  });
  return cb(void 0, video);
};

module.exports = {
  auth: auth,
  callback: callback,
  videos: videos,
  videoUrls: videoUrls
};

/*
//@ sourceMappingURL=vimeo.map
*/
