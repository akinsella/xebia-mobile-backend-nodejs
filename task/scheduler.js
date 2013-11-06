// Generated by CoffeeScript 1.6.3
var conf, cronJob, init, startJob, syncEventBrite, syncTwitter, syncVimeo, syncWordpress;

syncWordpress = require('./syncWordpress');

syncEventBrite = require('./syncEventBrite');

syncTwitter = require('./syncTwitter');

syncVimeo = require('./syncVimeo');

cronJob = require('cron').CronJob;

conf = require('../conf/config');

init = function() {
  console.log("Starting scheduler ...");
  startJob("Vimeo", conf.scheduler.syncVimeo, syncVimeo.synchronize);
  return console.log("Scheduler started ...");
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
