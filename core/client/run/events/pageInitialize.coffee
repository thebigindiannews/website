EventHandler = ($ga, $location, $log, $root, Notifications, Users) ->
  logger = $log.init EventHandler.tag
  logger.log "initialized"

  $root.bodyClasses ?= {}

  $root.$on "page:initialize", (event, value={}) ->
    logger.log "captured event!"

    # If the login property is set then check if the user is logged in.
    if value.needLogin then Users.withLogin redirect: true

    # Send a pageview in google analytics
    $ga.sendPageView()


EventHandler.tag = "event:pageInitialize"
EventHandler.$inject = [
  "$google/analytics"
  "$location"
  "$log"
  "$rootScope"
  "@notifications"
  "@models/users"
]
module.exports = EventHandler