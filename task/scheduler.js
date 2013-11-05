// Generated by CoffeeScript 1.6.3
var conf, cronJob, init, startJob, startSyncEventBrite, startSyncTwitter, startSyncVimeo, startSyncWordpress, syncEventBrite, syncTwitter, syncVimeo, syncWordpress;

syncWordpress = require('./syncWordpress');

syncEventBrite = require('./syncEventBrite');

syncTwitter = require('./syncTwitter');

syncVimeo = require('./syncVimeo');

cronJob = require('cron').CronJob;

conf = require('../conf/config');

init = function() {
  console.log("Starting scheduler ...");
  startSyncWordpress();
  startSyncTwitter();
  startSyncEventBrite();
  startSyncVimeo();
  return console.log("Scheduler started ...");
};

startSyncWordpress = function() {
  return startJob("Wordpress", conf.scheduler.syncWordpress, syncWordpress.synchronize);
};

startSyncEventBrite = function() {
  return startJob("EventBrite", conf.scheduler.syncEventBrite, syncEventBrite.synchronize);
};

startSyncTwitter = function() {
  return startJob("Twitter", conf.scheduler.syncTwitter, syncTwitter.synchronize);
};

startSyncVimeo = function() {
  return startJob("Vimeo", conf.scheduler.syncVimeo, syncVimeo.synchronize);
};

startJob = function(jobName, syncJobConf, synchronizeFunction) {
  var syncJob;
  console.log("Starting task 'Sync " + jobName + "' with cron expression: '" + syncJobConf.cron + "', timezone: '" + syncJobConf.timezone + "' and RunOnStart: '" + syncJobConf.runOnStart + "'");
  syncJob = new cronJob(syncJobConf.cron, synchronizeFunction, syncJobConf.runOnStart, syncJobConf.timezone);
  return syncJob.start();
};

module.exports = {
  init: init
};

/*
//@ sourceMappingURL=scheduler.map
*/
