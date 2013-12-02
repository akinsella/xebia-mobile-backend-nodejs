// Generated by CoffeeScript 1.6.3
var areChildrenTextOnly, async, cleanUpAttributes, filterEmptyChildren, jsdom, mapChildNode, mapChildNodes, mergeSiblingTexts, processAuthorInformations, processLanguageInformations, processTextElements, restructureChildren, stringifyChildren, transformPost, transformPostContent, _;

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
  return Array.insertArrayAt(index, arrayToInsert);
};

Array.prototype.removeAt = function(index) {
  return this.splice(index, 1);
};

transformPost = function(post, cb) {
  var author, category, comment, tag, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3;
  post.titlePlain = post.title_plain;
  delete post.title_plain;
  post.commentCount = post.comment_count;
  delete post.comment_count;
  post.commentStatus = post.comment_status;
  delete post.comment_status;
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
  processAuthorInformations(post);
  processLanguageInformations(post);
  return jsdom.env({
    html: post.content,
    src: [],
    done: function(err, window) {
      var e;
      if (err) {
        return cb(err);
      } else {
        try {
          post.structuredContent = cleanUpAttributes(processTextElements(mergeSiblingTexts(stringifyChildren(restructureChildren(filterEmptyChildren(mapChildNodes(window.document.body.childNodes, mapChildNode)))))));
        } catch (_error) {
          e = _error;
          console.log("Got some error: " + e.message);
          err = e;
          console.log(err.stack);
        }
        cb(err, post);
        return window.close();
      }
    }
  });
};

processAuthorInformations = function(post) {
  var components, e, firstname, gravatar, lastname, match, matches, twitter, username, _i, _len, _results;
  matches = post.content.match(/\[author.*\]/g);
  if (matches) {
    _results = [];
    for (_i = 0, _len = matches.length; _i < _len; _i++) {
      match = matches[_i];
      try {
        components = /\[author.*twitter="(.*)".*username="(.*)".*urls="(.*)".*gravatar="(.*)".*lastname="(.*)".*firstname="(.*)".*\]/.exec(match);
        console.log("Components: " + components);
        twitter = components[1];
        username = components[2];
        gravatar = components[4];
        lastname = components[5];
        firstname = components[6];
        _results.push(post.content = post.content.replace(match, "<author username=\"" + username + "\" firstname=\"" + firstname + "\" lastname=\"" + lastname + "\" gravatar=\"" + gravatar + "\" twitter=\"" + twitter + "\" />"));
      } catch (_error) {
        e = _error;
        console.log("entering catch block");
        console.log(e);
        _results.push(console.log("leaving catch block"));
      } finally {
        console.log("entering and leaving the finally block");
      }
    }
    return _results;
  }
};

processLanguageInformations = function(post) {
  var endTag, language, languages, startTag, _i, _len, _results;
  languages = ["java", "xml", "javascript", "cpp", "scala", "default"];
  _results = [];
  for (_i = 0, _len = languages.length; _i < _len; _i++) {
    language = languages[_i];
    startTag = "\\[" + language + "\\]";
    endTag = "\\[\\/" + language + "\\]";
    post.content = post.content.replace(new RegExp(startTag, "g"), "<code language=\"" + language + "\">");
    _results.push(post.content = post.content.replace(new RegExp(endTag, "g"), "</code>"));
  }
  return _results;
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
  } else if (childNode.nodeName === "AUTHOR") {
    element.attributes.push({
      key: "username",
      value: childNode.attributes.username.value
    });
    element.attributes.push({
      key: "firstname",
      value: childNode.attributes.firstname.value
    });
    element.attributes.push({
      key: "lastname",
      value: childNode.attributes.lastname.value
    });
    element.attributes.push({
      key: "gravatar",
      value: childNode.attributes.gravatar.value
    });
    element.attributes.push({
      key: "twitter",
      value: childNode.attributes.twitter.value
    });
  } else if (childNode.nodeName === "CODE") {
    element.attributes.push({
      key: "language",
      value: childNode.attributes.language ? childNode.attributes.language.value : "default"
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
  var child, href, index, _i, _len;
  for (index = _i = 0, _len = children.length; _i < _len; index = ++_i) {
    child = children[index];
    child.children = restructureChildren(child.children);
    if (child.type === "DIV") {
      children.removeAt(index);
      children.insertArrayAt(index, child.children);
    } else if (child.type === "A" && child.children.length === 1 && child.children[0].type === "IMG" && !child.text) {
      child.type = "IMG";
      href = _(child.attributes).find(function(attribute) {
        return attribute.key === "href";
      });
      child.attributes = [];
      child.attributes.push(_(child.children[0].attributes).find(function(attribute) {
        return attribute.key === "src";
      }));
      child.attributes.push(href);
      child.children = [];
    } else if (child.type === "P" && child.children.length === 1 && child.children[0].type === "IMG" && !child.text) {
      child.type = "IMG";
      child.attributes = [];
      child.attributes.push(_(child.children[0].attributes).find(function(attribute) {
        return attribute.key === "src";
      }));
      href = _(child.children[0].attributes).find(function(attribute) {
        return attribute.key === "href";
      });
      if (href) {
        child.attributes.push(_(child.children[0].attributes).find(function(attribute) {
          return attribute.key === "href";
        }));
      }
      child.children = [];
    } else if (child.type === "CODE" && child.children.length === 1 && child.children[0].type === "A") {
      child.type = "A";
      child.attributes = [];
      href = _(child.children[0].attributes).find(function(attribute) {
        return attribute.key === "href";
      });
      child.attributes.push(_(child.children[0].attributes).find(function(attribute) {
        return attribute.key === "href";
      }));
      child.children = [];
    }
  }
  return children;
};

processTextElements = function(children) {
  var child, _i, _len;
  for (_i = 0, _len = children.length; _i < _len; _i++) {
    child = children[_i];
    child.children = processTextElements(child.children);
    if (child.type === "#text") {
      child.type = "P";
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
    var _ref;
    return child.text && child.text.trim() || child.children.length || ((_ref = child.type) === "IMG");
  });
  return children;
};

stringifyChildren = function(children) {
  var child, _i, _len, _ref;
  for (_i = 0, _len = children.length; _i < _len; _i++) {
    child = children[_i];
    if (child.children.length) {
      if (areChildrenTextOnly(child.children) || ((_ref = child.type) === "TABLE")) {
        child.text = child.innerHTML();
        child.children = [];
      } else {
        stringifyChildren(child.children);
      }
    }
  }
  return children;
};

cleanUpAttributes = function(children) {
  var child, newChildren, _i, _len, _ref;
  newChildren = [];
  for (_i = 0, _len = children.length; _i < _len; _i++) {
    child = children[_i];
    if (child.children.length) {
      cleanUpAttributes(child.children);
    }
    delete child.children;
    if (child.text || ((_ref = child.type) === "IMG")) {
      newChildren.push(child);
    }
  }
  return newChildren;
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
    if (!child.children.length && ((_ref = child.type) === "#text" || _ref === "P" || _ref === "SPAN" || _ref === "EM" || _ref === "A" || _ref === "LI" || _ref === "STRONG" || _ref === "EM" || _ref === "AUTHOR")) {
      text = "" + text + (child.outerHTML());
    } else {
      if (text.length) {
        newChildren.push({
          type: "#text",
          text: "" + (text.trim()),
          children: []
        });
      }
      text = "";
      newChildren.push(child);
    }
  }
  if (text.length) {
    newChildren.push({
      type: "#text",
      text: "" + (text.trim()),
      children: []
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
  transformPost: transformPost
};

/*
//@ sourceMappingURL=postTransformer.map
*/
