// Generated by CoffeeScript 1.6.3
var areChildrenTextOnly, async, authorPosts, authors, baseUrl, categories, categoryPosts, datePosts, dates, filterEmptyChildren, jsdom, mapChildNode, mapChildNodes, mergeSiblingTexts, post, processRequest, recentPosts, removeChildrenWhenDescendantsAreTextOnly, restructureChildren, tagPosts, tags, transformPost, transformPostContent, utils, _;

utils = require('../lib/utils');

_ = require('underscore')._;

jsdom = require('jsdom');

async = require('async');

Array.prototype.insertArrayAt = function(index, arrayToInsert) {
  Array.prototype.splice.apply(this, [index, 0].concat(arrayToInsert));
  return this;
};

Array.prototype.insertAt = function(index) {
  var arrayToInsert;
  arrayToInsert = Array.prototype.splice.apply(arguments, [1]);
  return Array.insertArrayAt(this, index, arrayToInsert);
};

Array.prototype.removeAt = function(index) {
  return this.splice(index, 1);
};

baseUrl = "http://blog.xebia.fr";

processRequest = function(req, res, url, transform) {
  var options;
  res.charset = "UTF-8";
  options = utils.buildOptions(req, res, url, 5 * 60, transform);
  return utils.processRequest(options);
};

authors = function(req, res) {
  return processRequest(req, res, "" + baseUrl + "/wp-json-api/get_author_index?count=250", function(data, cb) {
    var author, _i, _len, _ref;
    delete data.status;
    _ref = data.authors;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      author = _ref[_i];
      author.firstname = author.first_name;
      delete author.first_name;
      author.lastname = author.last_name;
      delete author.last_name;
    }
    return cb(data);
  });
};

tags = function(req, res) {
  return processRequest(req, res, "" + baseUrl + "/wp-json-api/get_tag_index/?count=2000", function(data, cb) {
    var tag, _i, _len, _ref;
    delete data.status;
    _ref = data.tags;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      tag = _ref[_i];
      tag.postCount = tag.post_count;
      delete tag.post_count;
    }
    return cb(data);
  });
};

categories = function(req, res) {
  return processRequest(req, res, "" + baseUrl + "/wp-json-api/get_category_index?count=100", function(data, cb) {
    var category, _i, _len, _ref;
    delete data.status;
    _ref = data.categories;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      category = _ref[_i];
      category.postCount = category.post_count;
      delete category.post_count;
    }
    return cb(data);
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
    return cb(data);
  });
};

post = function(req, res) {
  var postId;
  postId = req.params.id;
  return processRequest(req, res, "" + baseUrl + "/wp-json-api/get_post?post_id=" + postId, function(data, cb) {
    delete data.status;
    delete data.previous_url;
    delete data.next_url;
    return transformPost(data.post, function(err, post) {
      if (!err && post) {
        data.post = post;
      }
      return cb(err, data);
    });
  });
};

recentPosts = function(req, res) {
  return processRequest(req, res, "" + baseUrl + "/wp-json-api/get_recent_posts", function(data, cb) {
    var _i, _len, _ref;
    delete data.status;
    data.total = data.count_total;
    delete data.count_total;
    _ref = data.posts;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      post = _ref[_i];
      transformPost(post);
    }
    return cb(err, data);
  });
};

authorPosts = function(req, res) {
  var authorId;
  authorId = req.params.id;
  return processRequest(req, res, "" + baseUrl + "/wp-json-api/get_author_posts?id=" + authorId, function(data, cb) {
    var _i, _len, _ref;
    _ref = data.posts;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      post = _ref[_i];
      transformPost(post);
    }
    return cb(data);
  });
};

tagPosts = function(req, res) {
  var tagId;
  tagId = req.params.id;
  return processRequest(req, res, "" + baseUrl + "/wp-json-api/get_tag_posts?id=" + tagId, function(data, cb) {
    var _i, _len, _ref;
    _ref = data.posts;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      post = _ref[_i];
      transformPost(post);
    }
    return cb(data);
  });
};

categoryPosts = function(req, res) {
  var categoryId;
  categoryId = req.params.id;
  return processRequest(req, res, "" + baseUrl + "/wp-json-api/get_category_posts?id=" + categoryId, function(data, cb) {
    var _i, _len, _ref;
    _ref = data.posts;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      post = _ref[_i];
      transformPost(post);
    }
    return cb(data);
  });
};

datePosts = function(req, res) {
  var month, year;
  year = req.params.year;
  month = req.params.month;
  return processRequest(req, res, "" + baseUrl + "/wp-json-api/get_date_posts_sync_data/?date=" + year + month + "$&count=1000");
};

transformPost = function(post, cb) {
  var author, category, comment, tag, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3;
  post.titlePlain = post.title_plain;
  delete post.title_plain;
  post.commentCount = post.comment_count;
  delete post.comment_count;
  post.commentStatus = post.comment_status;
  delete post.comment_status;
  delete post.title_plain;
  _ref = post.categories;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    category = _ref[_i];
    category.postCount = category.post_count;
    delete category.post_count;
  }
  _ref1 = post.tags;
  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
    tag = _ref1[_j];
    tag.postCount = tag.post_count;
    delete tag.post_count;
  }
  post.authors = [post.author];
  delete post.author;
  _ref2 = post.authors;
  for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
    author = _ref2[_k];
    author.firstname = author.first_name;
    delete author.firstname;
    author.lastname = author.last_name;
    delete author.last_name;
  }
  _ref3 = post.comments;
  for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
    comment = _ref3[_l];
    delete comment.parent;
  }
  return transformPostContent(post, cb);
};

transformPostContent = function(post, cb) {
  var components, firstname, gravatar, language, languages, lastname, match, matches, twitter, username, _i, _j, _len, _len1;
  matches = post.content.match(/\[author.*\]/g);
  console.log("Matches: " + matches);
  if (matches) {
    for (_i = 0, _len = matches.length; _i < _len; _i++) {
      match = matches[_i];
      components = /\[author.*twitter="(.*)".*username="(.*)".*urls="(.*)".*gravatar="(.*)".*lastname="(.*)".*firstname="(.*)".*\]/.exec(match);
      console.log("Components: " + components);
      twitter = components[1];
      username = components[2];
      gravatar = components[4];
      lastname = components[5];
      firstname = components[6];
      post.content = post.content.replace(match, "<author username=\"" + username + "\" firstname=\"" + firstname + "\" lastname=\"" + lastname + "\" gravatar=\"" + gravatar + "\" twitter=\"" + twitter + "\" />");
    }
  }
  languages = ["java"];
  for (_j = 0, _len1 = languages.length; _j < _len1; _j++) {
    language = languages[_j];
    post.content = post.content.replace(/\[java\]/g, "<code language=\"" + language + "\">");
    post.content = post.content.replace(/\[\/java\]/g, "</code>");
  }
  return jsdom.env({
    html: post.content,
    src: [],
    done: function(err, window) {
      if (err) {
        return cb(err);
      } else {
        post.structuredContent = mergeSiblingTexts(removeChildrenWhenDescendantsAreTextOnly(restructureChildren(filterEmptyChildren(mapChildNodes(window.document.body.childNodes, mapChildNode)))));
        cb(err, post);
        return window.close();
      }
    }
  });
};

mapChildNodes = function(childNodes, mapChildNode) {
  return _(childNodes).map(function(childNode) {
    return mapChildNode(childNode);
  });
};

mapChildNode = function(childNode) {
  var element;
  element = {
    type: childNode.nodeName,
    attributes: [],
    children: []
  };
  if (childNode.childNodes.length) {
    element.children = mapChildNodes(childNode.childNodes, mapChildNode);
  }
  if (childNode.nodeName === "#text") {
    element.text = childNode.nodeValue;
  } else if (childNode.nodeName === "IMG") {
    element.attributes.push({
      key: "src",
      value: childNode.src
    });
  } else if (childNode.nodeName === "A") {
    element.attributes.push({
      key: "href",
      value: childNode.href
    });
  }
  element.innerHTML = function() {
    if (!element.children.length) {
      return element.text;
    } else {
      return element.children.map(function(element) {
        return element.outerHTML();
      }).reduce(function(elt1, elt2) {
        return elt1 + elt2;
      });
    }
  };
  element.outerHTML = function() {
    var attribute, attributes, _ref;
    if (element.type === "#text") {
      return "" + element.text;
    } else if ((_ref = element.type) === "IMG") {
      if (element.attributes.length > 0) {
        attributes = ((function() {
          var _i, _len, _ref1, _results;
          _ref1 = element.attributes;
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            attribute = _ref1[_i];
            _results.push("" + attribute.key + "=\"" + attribute.value + "\"");
          }
          return _results;
        })()).reduce((function(attr1, attr2) {
          return "" + attr1 + " " + attr2;
        }), "");
        return "<" + element.type + " " + attributes + " />";
      } else {
        return "<" + element.type + " />";
      }
    } else {
      if (element.attributes.length > 0) {
        attributes = ((function() {
          var _i, _len, _ref1, _results;
          _ref1 = element.attributes;
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            attribute = _ref1[_i];
            _results.push("" + attribute.key + "=\"" + attribute.value + "\"");
          }
          return _results;
        })()).reduce((function(attr1, attr2) {
          return "" + attr1 + " " + attr2;
        }), "");
        return "<" + element.type + " " + attributes + ">" + (element.innerHTML()) + "</" + element.type + ">";
      } else {
        return "<" + element.type + ">" + (element.innerHTML()) + "</" + element.type + ">";
      }
    }
  };
  return element;
};

restructureChildren = function(children) {
  var child, index, _i, _len;
  for (index = _i = 0, _len = children.length; _i < _len; index = ++_i) {
    child = children[index];
    child.children = restructureChildren(child.children);
    if (child.type === "DIV") {
      children.removeAt(index);
      children.insertArrayAt(index, child.children);
    }
  }
  return children;
};

filterEmptyChildren = function(children) {
  var child, _i, _len;
  for (_i = 0, _len = children.length; _i < _len; _i++) {
    child = children[_i];
    child.children = filterEmptyChildren(child.children);
  }
  children = children.filter(function(child) {
    return child.type === "#text" && child.text.trim() || child.children.length;
  });
  return children;
};

removeChildrenWhenDescendantsAreTextOnly = function(children) {
  var child, _i, _len;
  for (_i = 0, _len = children.length; _i < _len; _i++) {
    child = children[_i];
    if (child.children.length) {
      if (areChildrenTextOnly(child.children)) {
        child.text = child.innerHTML();
        child.children = [];
      } else {
        removeChildrenWhenDescendantsAreTextOnly(child.children);
      }
    }
  }
  return children;
};

areChildrenTextOnly = function(children) {
  var child, _i, _len, _ref;
  if (!children) {
    return true;
  }
  for (_i = 0, _len = children.length; _i < _len; _i++) {
    child = children[_i];
    if (((_ref = child.type) === "VIDEO" || _ref === "IMG" || _ref === "CODE" || _ref === "TABLE" || _ref === "DIV" || _ref === "H1" || _ref === "H2" || _ref === "H3" || _ref === "H4" || _ref === "H5" || _ref === "H6") || !areChildrenTextOnly(child.children)) {
      return false;
    }
  }
  return true;
};

mergeSiblingTexts = function(children) {
  var child, index, newChildren, text, _i, _j, _len, _len1, _ref;
  newChildren = [];
  text = "";
  index = 0;
  for (_i = 0, _len = children.length; _i < _len; _i++) {
    child = children[_i];
    index++;
    if ((!child.children.length) && ((_ref = child.type) === "#text" || _ref === "P" || _ref === "SPAN" || _ref === "EM" || _ref === "A" || _ref === "LI" || _ref === "STRONG" || _ref === "EM")) {
      text = "" + text + (child.outerHTML());
    } else {
      if (text.length) {
        newChildren.push({
          type: "#text",
          text: "" + (text.trim())
        });
      }
      text = "";
      newChildren.push(child);
    }
  }
  if (text.length) {
    newChildren.push({
      type: "#text",
      text: "" + (text.trim())
    });
  }
  for (_j = 0, _len1 = children.length; _j < _len1; _j++) {
    child = children[_j];
    if (child.children.length) {
      child.children = mergeSiblingTexts(child.children);
    }
  }
  return newChildren;
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
