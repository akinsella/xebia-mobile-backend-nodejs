// Generated by CoffeeScript 1.6.3
var conf, cronJob, init, startJob, syncDevoxxBelgium, syncEventBrite, syncEventBriteNews, syncTwitterNews, syncVimeo, syncVimeoNews, syncWordpress, syncWordpressNews, syncWordpressPosts;

syncWordpress = require('./syncWordpress');

syncWordpressPosts = require('./syncWordpressPosts');

syncWordpressNews = require('./syncWordpressNews');

syncEventBrite = require('./syncEventBrite');

syncEventBriteNews = require('./syncEventBriteNews');

syncTwitterNews = require('./syncTwitterNews');

syncVimeo = require('./syncVimeo');

syncVimeoNews = require('./syncVimeoNews');

syncDevoxxBelgium = require('./syncDevoxxBelgium');

cronJob = require('cron').CronJob;

conf = require('../conf/config');

init = function() {
  console.log("Starting scheduler ...");
  startJob("WordpressPosts", conf.scheduler.syncWordpressPosts, syncWordpressPosts.synchronize);
  startJob("WordpressNews", conf.scheduler.syncWordpress, syncWordpressNews.synchronize);
  startJob("EventBrite", conf.scheduler.syncVimeo, syncEventBrite.synchronize);
  startJob("EventBriteNews", conf.scheduler.syncEventBrite, syncEventBriteNews.synchronize);
  startJob("TwitterNews", conf.scheduler.syncTwitter, syncTwitterNews.synchronize);
  startJob("Vimeo", conf.scheduler.syncVimeo, syncVimeo.synchronize);
  startJob("VimeoNews", conf.scheduler.syncVimeo, syncVimeoNews.synchronize);
  startJob("DevoxxBelgium", conf.scheduler.syncDevoxxBelgium, syncDevoxxBelgium.synchronize);
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
