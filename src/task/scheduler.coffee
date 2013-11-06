syncWordpress = require './syncWordpress'
syncEventBrite = require './syncEventBrite'
syncTwitter = require './syncTwitter'
syncVimeo = require './syncVimeo'

cronJob = require('cron').CronJob
conf = require '../conf/config'

init = () ->
	console.log "Starting scheduler ..."

	startJob "Wordpress", conf.scheduler.syncWordpress, syncWordpress.synchronize
	startJob "EventBrite", conf.scheduler.syncEventBrite, syncEventBrite.synchronize
	startJob "Twitter", conf.scheduler.syncTwitter, syncTwitter.synchronize
	startJob "Vimeo", conf.scheduler.syncVimeo, syncVimeo.synchronize

	console.log "Scheduler started ..."

startJob = (jobName, syncJobConf, synchronizeFunction) ->
	console.log "Starting task 'Sync #{jobName}' with cron expression: '#{syncJobConf.cron}', timezone: '#{syncJobConf.timezone}' and RunOnStart: '#{syncJobConf.runOnStart}'"
	syncJob = new cronJob syncJobConf.cron, synchronizeFunction, syncJobConf.runOnStart, syncJobConf.timezone
	syncJob.start()


module.exports =
	init: init
