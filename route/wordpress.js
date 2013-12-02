// Generated by CoffeeScript 1.6.3
var Author, Category, DetailedPost, Post, Tag, async, authorPosts, authors, baseUrl, categories, categoryPosts, config, datePosts, dates, fs, jsdom, post, processRequest, recentPosts, tagPosts, tags, utils, _;

utils = require('../lib/utils');

_ = require('underscore')._;

jsdom = require('jsdom');

async = require('async');

fs = require('fs');

config = require('../conf/config');

Tag = require('../model/tag');

Category = require('../model/category');

Author = require('../model/author');

Post = require('../model/post');

DetailedPost = require('../model/detailedPost');

baseUrl = "http://blog.xebia.fr";

processRequest = function(req, res, url, transform) {
  var options;
  res.charset = "UTF-8";
  options = utils.buildOptions(req, res, url, 5 * 60, transform);
  return utils.processRequest(options);
};

authors = function(req, res) {
  return Author.find({}).sort("name").exec(function(err, authors) {
    if (err) {
      return res.json(500, {
        message: "Server error: " + err.message
      });
    } else {
      authors = authors.map(function(author) {
        author = author.toObject();
        delete author.__v;
        delete author._id;
        return author;
      });
      return res.json(authors);
    }
  });
};

tags = function(req, res) {
  return Tag.find({}).sort("title").exec(function(err, tags) {
    if (err) {
      return res.json(500, {
        message: "Server error: " + err.message
      });
    } else {
      tags = tags.map(function(tag) {
        tag = tag.toObject();
        delete tag.__v;
        delete tag._id;
        return tag;
      });
      return res.json(tags);
    }
  });
};

categories = function(req, res) {
  return Category.find({}).sort("title").exec(function(err, categories) {
    if (err) {
      return res.json(500, {
        message: "Server error: " + err.message
      });
    } else {
      categories = categories.map(function(category) {
        category = category.toObject();
        delete category.__v;
        delete category._id;
        return category;
      });
      return res.json(categories);
    }
  });
};

dates = function(req, res) {
  return processRequest(req, res, "" + baseUrl + "/wp-json-api/get_date_index?count=1000", function(data, cb) {
    var key, value, _ref;
    delete data.status;
    delete data.permalinks;
    _ref = data.tree;
    for (key in _ref) {
      value = _ref[key];
      data[key] = value;
    }
    delete data.tree;
    return cb(void 0, data);
  });
};

post = function(req, res) {
  var postId;
  postId = req.params.id;
  return DetailedPost.findOne({
    id: postId
  }, function(err, post) {
    if (err) {
      return res.json(500, {
        message: "Server error: " + err.message
      });
    } else if (!post) {
      return res.json(404, {
        message: "Not Found"
      });
    } else {
      post = post.toObject();
      delete post._id;
      delete post.__v;
      post.tags.forEach(function(tag) {
        return delete tag._id;
      });
      post.categories.forEach(function(category) {
        return delete category._id;
      });
      post.authors.forEach(function(author) {
        return delete author._id;
      });
      post.attachments.forEach(function(attachment) {
        return delete attachment._id;
      });
      post.comments.forEach(function(comment) {
        return delete comment._id;
      });
      if (post.structuredContent) {
        post.structuredContent.forEach(function(scItem) {
          if (scItem.attributes) {
            post.attributes.forEach(function(attribute) {
              return delete attribute._id;
            });
          }
          return delete scItem._id;
        });
      }
      return res.json({
        post: post
      });
    }
  });
};

recentPosts = function(req, res) {
  var limit, payload;
  if (config.offlineMode) {
    res.charset = 'UTF-8';
    payload = JSON.parse(fs.readFileSync("" + __dirname + "/../data/wp_recent_post.json", "utf-8"));
    return res.send(payload);
  } else {
    limit = 50;
    return Post.count({}, function(error, count) {
      var pages, total;
      total = count;
      pages = total % 50 === 0 ? total / limit : total / limit + 1;
      return Post.find({}).sort("-date").limit(limit).exec(function(err, posts) {
        if (err) {
          return res.json(500, {
            message: "Server error: " + err.message
          });
        } else {
          return res.json({
            count: limit,
            pages: pages,
            total: total,
            posts: posts
          });
        }
      });
    });
  }
};

authorPosts = function(req, res) {
  var authorId;
  authorId = req.params.id;
  return Post.find({
    "author.id": Number(authorId)
  }).sort("-date").exec(function(err, posts) {
    if (err) {
      return res.json(500, {
        message: "Server error: " + err.message
      });
    } else {
      return res.json({
        posts: posts
      });
    }
  });
};

tagPosts = function(req, res) {
  var tagId;
  tagId = req.params.id;
  return Post.find({
    "tags.id": Number(tagId)
  }).sort("-date").exec(function(err, posts) {
    if (err) {
      return res.json(500, {
        message: "Server error: " + err.message
      });
    } else {
      return res.json({
        posts: posts
      });
    }
  });
};

categoryPosts = function(req, res) {
  var categoryId;
  categoryId = req.params.id;
  return Post.find({
    "categories.id": Number(categoryId)
  }).sort("-date").exec(function(err, posts) {
    if (err) {
      return res.json(500, {
        message: "Server error: " + err.message
      });
    } else {
      return res.json({
        posts: posts
      });
    }
  });
};

datePosts = function(req, res) {
  var month, year;
  year = req.params.year;
  month = req.params.month;
  return processRequest(req, res, "" + baseUrl + "/wp-json-api/get_date_posts_sync_data/?date=" + year + month + "$&count=1000");
};

module.exports = {
  tags: tags,
  categories: categories,
  authors: authors,
  dates: dates,
  recentPosts: recentPosts,
  post: post,
  authorPosts: authorPosts,
  tagPosts: tagPosts,
  categoryPosts: categoryPosts,
  datePosts: datePosts
};

/*
//@ sourceMappingURL=wordpress.map
*/
