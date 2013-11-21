// Generated by CoffeeScript 1.6.3
var app, config, express, gracefullyClosing, httpServer, newrelic, requestLogger, scheduler, start;

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

scheduler = require('./task/scheduler');

scheduler.init();

express = require('express');

requestLogger = require('./lib/requestLogger');

console.log("Application Name: " + config.appname);

console.log("Env: " + (JSON.stringify(config)));

app = express();

gracefullyClosing = false;

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
