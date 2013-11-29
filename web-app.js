// Generated by CoffeeScript 1.6.3
var MongoStore, allowCrossDomain, app, auth, authMiddleware, authService, client, config, device, express, fs, gracefullyClosing, httpServer, mongo, newrelic, news, notification, oauth2, passport, path, requestLogger, role, security, start, user, util, utils;

start = new Date();

config = require('./conf/config');

if (config.devMode) {
  console.log("Dev Mode enabled.");
}

if (config.offlineMode) {
  console.log("Offline mode enabled.");
}

if (config.monitoring.newrelic.apiKey) {
  console.log("Initializing NewRelic with apiKey: '" + config.monitoring.newrelic.apiKey + "'");
  newrelic = require('newrelic');
}

fs = require('fs');

path = require('path');

util = require('util');

express = require('express');

news = require('./route/news');

device = require('./route/device');

notification = require('./route/notification');

MongoStore = require('connect-mongo')(express);

mongo = require('./lib/mongo');

passport = require('passport');

role = require('./lib/connect-roles-fixed');

requestLogger = require('./lib/requestLogger');

allowCrossDomain = require('./lib/allowCrossDomain');

utils = require('./lib/utils');

security = require('./lib/security');

auth = require('./route/auth');

client = require('./route/client');

user = require('./route/user');

oauth2 = require('./oauth2');

authMiddleware = require('./middleware/authMiddleware');

authService = require('./service/authService');

console.log("Application Name: " + config.appname);

console.log("Env: " + (JSON.stringify(config)));

app = express();

gracefullyClosing = false;

passport.serializeUser(authService.serializeUser);

passport.deserializeUser(authService.deserializeUser);

passport.use(authMiddleware.GoogleStrategy);

passport.use(authMiddleware.BasicStrategy);

passport.use(authMiddleware.ClientPasswordStrategy);

passport.use(authMiddleware.BearerStrategy);

role.use(authService.checkRoleAnonymous);

role.use(authService.ROLE_AGENT, authService.checkRoleAgent);

role.use(authService.ROLE_SUPER_AGENT, authService.checkRoleSuperAgent);

role.use(authService.ROLE_ADMIN, authService.checkRoleAdmin);

role.setFailureHandler(authService.failureHandler);

app.configure(function() {
  console.log("Environment: " + (app.get('env')));
  app.set('port', config.port || process.env.PORT || 9000);
  app.use(function(req, res, next) {
    if (!gracefullyClosing) {
      return next();
    }
    res.setHeader("Connection", "close");
    return res.send(502, "Server is in the process of restarting");
  });
  app.use(function(req, res, next) {
    req.forwardedSecure = req.headers["x-forwarded-proto"] === "https";
    return next();
  });
  app.use('/', express["static"]("" + __dirname + "/public"));
  app.use(express.favicon());
  app.use(express.bodyParser());
  app.use(express.cookieParser());
  app.use(express.session({
    secret: process.env.SESSION_SECRET,
    maxAge: new Date(Date.now() + 3600000),
    store: new MongoStore({
      db: config.mongo.dbname,
      host: config.mongo.hostname,
      port: config.mongo.port,
      username: config.mongo.username,
      password: config.mongo.password,
      collection: "sessions",
      auto_reconnect: true
    })
  }));
  app.use(express.logger());
  app.use(express.methodOverride());
  app.use(allowCrossDomain());
  app.use(requestLogger());
  app.use(passport.initialize());
  app.use(passport.session());
  app.use(role);
  app.use(app.router);
  return app.use(function(err, req, res, next) {
    console.error("Error: " + err + ", Stacktrace: " + err.stack);
    return res.send(500, "Something broke! Error: " + err + ", Stacktrace: " + err.stack);
  });
});

app.configure('development', function() {
  return app.use(express.errorHandler({
    dumpExceptions: true,
    showStack: true
  }));
});

app.configure('production', function() {
  return app.use(express.errorHandler());
});

app.get("/users/me", security.ensureAuthenticated, user.me);

app.post('/login', auth.login);

app.get('/login', auth.loginForm);

app.get('/logout', auth.logout);

app.get('/auth/google', passport.authenticate('google', {
  failureRedirect: '/#/login'
}));

app.get('/auth/google/callback', passport.authenticate('google', {
  failureRedirect: '/#/login'
}), auth.authGoogleCallback);

app["delete"]("/news/:id", security.ensureAuthenticated, news.removeById);

app.post("/news", security.ensureAuthenticated, news.create);

app.get("/news/unfiltered", security.ensureAuthenticated, news.list);

app.get("/news", security.ensureAuthenticated, news.listUnfiltered);

app.get("/news/:id", security.ensureAuthenticated, news.findById);

app["delete"]("/devices/:id", security.ensureAuthenticated, device.removeById);

app.post("/devices", security.ensureAuthenticated, device.create);

app.get("/devices", security.ensureAuthenticated, device.list);

app.get("/devices/:id", security.ensureAuthenticated, device.findById);

app["delete"]("/clients/:id", security.ensureAuthenticated, client.removeById);

app.post("/clients", security.ensureAuthenticated, client.create);

app.get("/clients", security.ensureAuthenticated, client.list);

app.get("/clients/:id", security.ensureAuthenticated, client.findById);

app.post("/users", security.ensureAuthenticated, user.create);

app.get("/users", security.ensureAuthenticated, user.list);

app.get("/users/me", security.ensureAuthenticated, user.me);

app.get("/users/:id", security.ensureAuthenticated, user.findById);

app["delete"]("/users/:id", security.ensureAuthenticated, user.removeById);

app["delete"]("/notifications", security.ensureAuthenticated, notification.removeById);

app.post("/notifications", security.ensureAuthenticated, notification.create);

app.get("/notifications", security.ensureAuthenticated, notification.list);

app.get("/notifications/:id/push", security.ensureAuthenticated, notification.push);

app.get("/notifications/:id", security.ensureAuthenticated, notification.findById);

httpServer = app.listen(app.get('port'));

process.on('SIGTERM', function() {
  console.log("Received kill signal (SIGTERM), shutting down gracefully.");
  gracefullyClosing = true;
  httpServer.close(function() {
    console.log("Closed out remaining connections.");
    return process.exit();
  });
  return setTimeout(function() {
    console.error("Could not close connections in time, forcefully shutting down");
    return process.exit(1);
  }, 30 * 1000);
});

process.on('uncaughtException', function(err) {
  console.error("An uncaughtException was found, the program will end. " + err + ", stacktrace: " + err.stack);
  return process.exit(1);
});

console.log("Express listening on port: " + (app.get('port')));

console.log("Started in " + ((new Date().getTime() - start.getTime()) / 1000) + " seconds");

/*
//@ sourceMappingURL=web-app.map
*/