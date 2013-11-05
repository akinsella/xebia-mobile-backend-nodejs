syncWordpress = require './syncWordpress'
syncEventBrite = require './syncEventBrite'
syncTwitter = require './syncTwitter'
syncVimeo = require './syncVimeo'

cronJob = require('cron').CronJob
conf = require '../conf/config'

init = () ->
	console.log "Starting scheduler ..."

	startSyncWordpress()
	startSyncTwitter()
	startSyncEventBrite()
	startSyncVimeo()

	console.log "Scheduler started ..."

startSyncWordpress = () ->
	startJob "Wordpress", conf.scheduler.syncWordpress, syncWordpress.synchronize

startSyncEventBrite = () ->
	startJob "EventBrite", conf.scheduler.syncEventBrite, syncEventBrite.synchronize

startSyncTwitter = () ->
	startJob "Twitter", conf.scheduler.syncTwitter, syncTwitter.synchronize

startSyncVimeo = () ->
	startJob "Vimeo", conf.scheduler.syncVimeo, syncVimeo.synchronize

startJob = (jobName, syncJobConf, synchronizeFunction) ->
	console.log "Starting task 'Sync #{jobName}' with cron expression: '#{syncJobConf.cron}', timezone: '#{syncJobConf.timezone}' and RunOnStart: '#{syncJobConf.runOnStart}'"
	syncJob = new cronJob syncJobConf.cron, synchronizeFunction, syncJobConf.runOnStart, syncJobConf.timezone
	syncJob.start()


module.exports =
	init: init
