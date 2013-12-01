// Generated by CoffeeScript 1.6.3
var News, create, findById, list, listUnfiltered, mapNews, moment, processRequest, removeById, utils, _;

utils = require('../lib/utils');

News = require('../model/news');

_ = require('underscore')._;

moment = require('moment');

processRequest = function(req, res, url, transform) {
  var options;
  options = utils.buildOptions(req, res, url, 5 * 60, transform);
  return utils.processRequest(options);
};

listUnfiltered = function(req, res) {
  return News.find({}).sort("-publicationDate").limit(100).exec(function(err, news) {
    if (err) {
      return utils.responseData(500, "Could not find news - Error: " + err.message, void 0, {
        req: req,
        res: res
      });
    } else {
      return utils.responseData(200, void 0, news.map(mapNews), {
        req: req,
        res: res
      });
    }
  });
};

list = function(req, res) {
  return News.find({
    draft: false
  }.sort("-publicationDate").limit(100).exec(function(err, news) {
    if (err) {
      return utils.responseData(500, "Could not find news - Error: " + err.message, void 0, {
        req: req,
        res: res
      });
    } else {
      return utils.responseData(200, void 0, mapNews(news), {
        req: req,
        res: res
      });
    }
  }));
};

findById = function(req, res) {
  return News.findOne({
    id: req.params.id
  }, function(err, news) {
    if (err) {
      utils.responseData(500, "Could not find news - Error: " + err.message, void 0, {
        req: req,
        res: res
      });
    }
    if (!news) {
      return utils.responseData(404, "Not Found", void 0, {
        req: req,
        res: res
      });
    } else {
      return utils.responseData(200, void 0, news, {
        req: req,
        res: res
      });
    }
  });
};

removeById = function(req, res) {
  return News.findOneAndRemove({
    id: req.params.id
  }, function(err, news) {
    if (err) {
      utils.responseData(500, "Could not remove news - Error: " + err.message, void 0, {
        req: req,
        res: res
      });
    }
    if (!news) {
      return utils.responseData(404, "Not Found", void 0, {
        req: req,
        res: res
      });
    } else {
      return utils.responseData(204, void 0, news, {
        req: req,
        res: res
      });
    }
  });
};

create = function(req, res) {
  var news;
  news = new News(req.body);
  return news.save(function(err) {
    if (err) {
      return utils.responseData(500, "Could not save news", req.body, {
        req: req,
        res: res
      });
    } else {
      return utils.responseData(201, "Created", news, {
        req: req,
        res: res
      });
    }
  });
};

mapNews = function(news) {
  return {
    id: news.id,
    content: news.content,
    createdAt: news.createdAt,
    draft: news.draft,
    imageUrl: news.imageUrl,
    lastModified: news.lastModified,
    publicationDate: news.publicationDate,
    targetUrl: news.targetUrl,
    title: news.title,
    author: news.author,
    type: news.type,
    typeId: news.typeId,
    metadata: news.metadata,
    publicationDate: moment(news.publicationDate).format("YYYY-MM-DD HH:mm:ss"),
    lastModified: moment(news.lastModified).format("YYYY-MM-DD HH:mm:ss"),
    createdAt: moment(news.createdAt).format("YYYY-MM-DD HH:mm:ss"),
    publicationDate: moment(news.publicationDate).format("YYYY-MM-DD HH:mm:ss")
  };
};

module.exports = {
  list: list,
  listUnfiltered: listUnfiltered,
  findById: findById,
  create: create,
  removeById: removeById
};

/*
//@ sourceMappingURL=news.map
*/
