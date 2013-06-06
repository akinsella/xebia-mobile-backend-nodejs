// Generated by CoffeeScript 1.6.2
var account, auth_google, auth_google_return, login, logout, security, utils,
  _this = this;

utils = require('../lib/utils');

security = require('../lib/security');

account = function(req, res) {
  res.render('account', {
    user: req.user
  });
};

login = function(req, res) {
  res.render('login', {
    user: req.user
  });
};

auth_google = function(req, res) {
  res.redirect('/');
};

auth_google_return = function(req, res) {
  res.redirect('/');
};

logout = function(req, res) {
  req.logout();
  res.redirect('/');
};

module.exports = {
  account: account,
  login: login,
  auth_google: auth_google,
  auth_google_return: auth_google_return,
  logout: logout
};
