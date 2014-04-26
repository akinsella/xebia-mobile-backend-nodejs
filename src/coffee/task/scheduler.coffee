logger = require 'winston'
cronJob = require('cron').CronJob

conf = require '../conf/config'

syncWordpress = require './syncWordpress'
syncWordpressPosts = require './syncWordpressPosts'
syncWordpressNews = require './syncWordpressNews'
syncEventBrite = require './syncEventBrite'
syncEventBriteNews = require './syncEventBriteNews'
syncTwitterNews = require './syncTwitterNews'
syncVimeo = require './syncVimeo'
syncVimeoNews = require './syncVimeoNews'
syncDevoxxBelgium = require './syncDevoxxBelgium'
syncDevoxxFrance = require './syncDevoxxFrance'
syncMixIT = syncDevoxxFrance

init = () ->
	logger.info "Starting scheduler ..."

	startJob "WordpressPosts", conf.scheduler.syncWordpressPosts, syncWordpressPosts.synchronize
	startJob "WordpressNews", conf.scheduler.syncWordpress, syncWordpressNews.synchronize
	startJob "EventBrite", conf.scheduler.syncVimeo, syncEventBrite.synchronize
	startJob "EventBriteNews", conf.scheduler.syncEventBrite, syncEventBriteNews.synchronize
	startJob "TwitterNews", conf.scheduler.syncTwitter, syncTwitterNews.synchronize
	startJob "Vimeo", conf.scheduler.syncVimeo, syncVimeo.synchronize
	startJob "VimeoNews", conf.scheduler.syncVimeo, syncVimeoNews.synchronize
#	startJob "Devoxx Belgium 2010", conf.scheduler.syncDevoxxBelgium, syncDevoxxBelgium.synchronize(1, 2010)
#	startJob "Devoxx Belgium 2011", conf.scheduler.syncDevoxxBelgium, syncDevoxxBelgium.synchronize(4, 2011)
#	startJob "Devoxx France 2012", conf.scheduler.syncDevoxxBelgium, syncDevoxxBelgium.synchronize(6, 2012)
#	startJob "Devoxx Belgium 2012", conf.scheduler.syncDevoxxBelgium, syncDevoxxBelgium.synchronize(7, 2012)
#	startJob "Devoxx France 2013", conf.scheduler.syncDevoxxBelgium, syncDevoxxBelgium.synchronize(8, 2013)
#	startJob "Devoxx Uk 2013", conf.scheduler.syncDevoxxBelgium, syncDevoxxBelgium.synchronize(9, 2013)
#	startJob "Devoxx Belgium 2013", conf.scheduler.syncDevoxxBelgium, syncDevoxxBelgium.synchronize(10, 2013)
#	startJob "Devoxx France 2014", conf.scheduler.syncDevoxxFrance, syncDevoxxFrance.synchronize(11, "devoxxfr", 2014)
#	startJob "Devoxx Uk 2014", conf.scheduler.syncDevoxxFrance, syncDevoxxFrance.synchronize(11, "devoxxfr", 2014)
#	startJob "Mix-IT 2014", conf.scheduler.syncMixIT, syncMixIT.synchronize(13, "mixit", 2014)

logger.info "Scheduler started ..."

startJob = (jobName, syncJobConf, synchronizeFunction) ->
	logger.info "Starting task 'Sync #{jobName}' with cron expression: '#{syncJobConf.cron}', timezone: '#{syncJobConf.timezone}' and RunOnStart: '#{syncJobConf.runOnStart}'"
	syncJob = new cronJob syncJobConf.cron, synchronizeFunction, syncJobConf.runOnStart, syncJobConf.timezone
	syncJob.start()


module.exports =
	init: init
