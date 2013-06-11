// Generated by CoffeeScript 1.6.2
var ownerProps, processRequest, public_members, repoProps, repos, utils, _,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

utils = require('../lib/utils');

_ = require('underscore')._;

processRequest = function(req, res, url, transform) {
  var options;

  options = utils.buildOptions(req, res, url, 5 * 60, transform);
  utils.processRequest(options);
};

repoProps = ["id", "name", "full_name", "description", "language", "owner", "html_url", "homepage", "has_wiki", "has_issues", "has_downloads", "fork", "watchers", "forks", "open_issues", "size", "pushed_at", "created_at", "updated_at"];

ownerProps = ["id", "login", "gravatar_id", "avatar_url"];

repos = function(req, res) {
  return processRequest(req, res, "https://api.github.com/orgs/xebia-france/repos", function(data) {
    _(data).each(function(repo) {
      var oKey, rKey;

      for (rKey in repo) {
        if (!(__indexOf.call(repoProps, rKey) >= 0)) {
          delete repo[rKey];
        }
        for (oKey in repo.owner) {
          if (!(__indexOf.call(ownerProps, oKey) >= 0)) {
            delete repo.owner[oKey];
          }
        }
      }
      return repo;
    });
    return data;
  });
};

public_members = function(req, res) {
  return processRequest(req, res, "https://api.github.com/orgs/xebia-france/public_members", function(data) {
    _(data).each(function(owner) {
      var oKey;

      for (oKey in owner) {
        if (!(__indexOf.call(ownerProps, oKey) >= 0)) {
          delete owner[oKey];
        }
      }
      return owner;
    });
    return data;
  });
};

module.exports = {
  repos: repos,
  public_members: public_members
};
