syncWordpress = require './syncWordpress'
cronJob = require('cron').CronJob
conf = require '../conf/config'

init = () ->
	console.log "Starting scheduler ..."
	console.log "Starting task 'syncTask' with cron expression: '#{conf.scheduler.syncWordpress.cron}', timezone: '#{conf.scheduler.syncWordpress.timezone}' and RunOnStart: '#{conf.scheduler.syncWordpress.runOnStart}'"
	syncJob = new cronJob conf.scheduler.syncWordpress.cron, syncWordpress.synchronize, conf.scheduler.syncWordpress.runOnStart, conf.scheduler.syncWordpress.timezone
	syncJob.start()
	console.log "Scheduler started ..."

module.exports =
	init: init
