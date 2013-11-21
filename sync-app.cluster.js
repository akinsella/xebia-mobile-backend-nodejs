// Generated by CoffeeScript 1.6.3
var cluster, fs, http, recluster, util;

fs = require("fs");

util = require("util");

http = require("http");

recluster = require("recluster");

cluster = recluster("" + __dirname + "/app.js");

cluster.run();

fs.watchFile("package.json", function(curr, prev) {
  console.log("Package.json changed, reloading cluster...");
  return cluster.reload();
});

process.on("SIGUSR2", function() {
  console.log("Got SIGUSR2, reloading cluster...");
  return cluster.reload();
});

console.log("Spawned cluster, kill -s SIGUSR2 " + process.pid + " to reload");

/*
//@ sourceMappingURL=sync-app.cluster.map
*/
