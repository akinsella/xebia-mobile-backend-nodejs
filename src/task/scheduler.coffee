syncWordpress = require './syncWordpress'
syncWordpressPosts = require './syncWordpressPosts'
syncWordpressNews = require './syncWordpressNews'
syncEventBrite = require './syncEventBrite'
syncEventBriteNews = require './syncEventBriteNews'
syncTwitterNews = require './syncTwitterNews'
syncVimeo = require './syncVimeo'
syncVimeoNews = require './syncVimeoNews'

cronJob = require('cron').CronJob
conf = require '../conf/config'

init = () ->
	console.log "Starting scheduler ..."

	syncVimeo.synchronize()

# 	startJob "WordpressPosts", conf.scheduler.syncWordpressPosts, syncWordpressPosts.synchronize
#	startJob "WordpressNews", conf.scheduler.syncWordpress, syncWordpressNews.synchronize
#	startJob "EventBrite", conf.scheduler.syncVimeo, syncEventBrite.synchronize
#	startJob "EventBriteNews", conf.scheduler.syncEventBrite, syncEventBriteNews.synchronize
#	startJob "TwitterNews", conf.scheduler.syncTwitter, syncTwitterNews.synchronize
#	startJob "Vimeo", conf.scheduler.syncVimeo, syncVimeo.synchronize
#	startJob "VimeoNews", conf.scheduler.syncVimeo, syncVimeoNews.synchronize

	console.log "Scheduler started ..."

startJob = (jobName, syncJobConf, synchronizeFunction) ->
	console.log "Starting task 'Sync #{jobName}' with cron expression: '#{syncJobConf.cron}', timezone: '#{syncJobConf.timezone}' and RunOnStart: '#{syncJobConf.runOnStart}'"
	syncJob = new cronJob syncJobConf.cron, synchronizeFunction, syncJobConf.runOnStart, syncJobConf.timezone
	syncJob.start()


module.exports =
	init: init
