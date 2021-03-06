cron = require "cron"


Initializer = module.exports = (IoC, settings) ->
  name = "[cron]"
  cronJob = cron.CronJob
  logger = IoC.create "igloo/logger"

  # Start initializing the different cron scripts we have..
  # backupDatabase = IoC.create "cron/backup-database"
  clearCache = IoC.create "cron/clear-cache"
  fetchArticles = IoC.create "cron/fetch-articles"
  # emailReport = IoC.create "cron/email-report"
  # deleteBadUsers = IoC.create "cron/delete-bad-users"
  # expireClassifieds = IoC.create "cron/expire-classifieds"
  # rotateLogfiles = IoC.create "cron/rotate-logfiles"


  ###
    This function runs daily at 9PM.
  ###
  cronDaily = ->
    logger.info name, "running daily cron scripts"
    # if settings.server.env == "production" then emailReport()


  ###
    This function runs at the start of every hour.
  ###
  cronHourly = ->
    logger.info name, "running hourly cron scripts"
    do clearCache


  ###
    This function runs every Friday at 1AM. Call maintenance functions in here.
  ###
  cronWeekly = ->
    logger.info name, "running weekly cron scripts"
    # backupDatabase()


  ###
    This function runs everyday in 6 hour intervals.
  ###
  cronQuarterly = ->
    logger.info name, "running quarterly cron scripts"
    do fetchArticles


  # Setup the cron tasks
  new cronJob "0  0  *   *  *  *", cronHourly,     null, true, "Asia/Kuwait"
  new cronJob "0  0  1   *  *  5", cronWeekly,     null, true, "Asia/Kuwait"
  new cronJob "0  0  21  *  *  *", cronDaily,      null, true, "Asia/Kuwait"
  new cronJob "0  0  */6 *  *  *", cronQuarterly,  null, true, "Asia/Kuwait"


Initializer["@require"]  =[
  "$container"
  "igloo/settings"
]
Initializer["@singleton"] = true