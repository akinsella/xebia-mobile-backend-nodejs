// Generated by CoffeeScript 1.6.2
/*
Module dependencies.
*/

var account, index, login, loginForm, logout, passport;

passport = require('passport');

index = function(req, res) {
  return res.send("OAuth 2.0 Server");
};

loginForm = function(req, res) {
  return res.render("login");
};

login = passport.authenticate("local", {
  successReturnToOrRedirect: "/",
  failureRedirect: "/login"
});

logout = function(req, res) {
  req.logout();
  return res.redirect("/");
};

account = function(req, res) {
  return res.render("account", {
    user: req.user
  });
};

module.exports = {
  index: index,
  account: account,
  login: login,
  loginForm: loginForm,
  logout: logout
};
