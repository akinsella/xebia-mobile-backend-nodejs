// Generated by CoffeeScript 1.6.3
var MongoStore, app, auth, authMiddleware, authService, config, express, gracefullyClosing, httpServer, mongo, newrelic, passport, requestLogger, role, scheduler, security, start, sync, vimeo;

start = new Date();

config = require('./conf/config');

vimeo = require('./route/sync/vimeo');

sync = require('./route/sync');

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

express = require('express');

MongoStore = require('connect-mongo')(express);

mongo = require('./lib/mongo');

passport = require('passport');

role = require('./lib/connect-roles-fixed');

security = require('./lib/security');

auth = require('./route/auth');

authMiddleware = require('./middleware/authMiddleware');

authService = require('./service/authService');

scheduler = require('./task/scheduler');

scheduler.init();

requestLogger = require('./lib/requestLogger');

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
  app.use(express.bodyParser());
  app.use(express.logger());
  app.use(express.methodOverride());
  app.use(requestLogger());
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

app.get("/sync/vimeo/oauth", vimeo.auth);

app.get("/sync/vimeo/oauth/callback", vimeo.callback);

app.get("/sync/wordpress", security.ensureAuthenticated, sync.syncWordpress);

app.get("/sync/wordpress/posts", security.ensureAuthenticated, sync.syncWordpressPosts);

app.get("/sync/wordpress/news", security.ensureAuthenticated, sync.syncWordpressNews);

app["delete"]("/sync/wordpress/data", security.ensureAuthenticated, sync.removeBlogData);

app["delete"]("/sync/wordpress/posts", security.ensureAuthenticated, sync.removeBlogPosts);

app.get("/sync/eventbrite", security.ensureAuthenticated, sync.syncEventBrite);

app.get("/sync/eventbrite/news", security.ensureAuthenticated, sync.syncEventBriteNews);

app["delete"]("/sync/events", security.ensureAuthenticated, sync.removeEvents);

app.get("/sync/vimeo", security.ensureAuthenticated, sync.syncVimeo);

app.get("/sync/vimeo/news", security.ensureAuthenticated, sync.syncVimeoNews);

app["delete"]("/sync/videos", security.ensureAuthenticated, sync.removeVideos);

app.get("/sync/twitter/news", security.ensureAuthenticated, sync.syncTwitterNews);

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
//@ sourceMappingURL=sync-app.map
*/
