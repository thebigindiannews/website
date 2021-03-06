Controller = ($http, $location, $log, $scope, $window, Notifications, Session) ->
  logger = $log.init Controller.tag
  logger.log "initializing"
  $scope.$emit "page:initialize"

  prompted = false
  $scope.formClasses = {}
  $scope.login = {}
  $scope.$emit "page:start"

  $scope.goto = (i) ->
    $scope.page = i
    promted = false


  $scope.$watch "login.username", (value) ->
    # TODO: Poll the server to see if username is valid
    $scope.usernameValid = value?


  $scope.goSignup = -> $location.path "/signup"


  $scope.doLogin = (data) ->
    $scope.formClasses = loading: $scope.formLoading = true

    Session.login $scope.login
    .then (user) ->
      # Get the redirect URL
      getQuery = $location.search() or {}
      redirectURL = getQuery.redirectTo or "/"
      logger.info "redirecting to", redirectURL

      # Redirect!
      $location.url decodeURIComponent redirectURL

      # Give a notification for a succesful login.
      Notifications.success "login_success"

    .catch (response) ->
      Notifications.error "login_invalid"
      logger.error response.data, response.status
    .finally -> $scope.formClasses = loading: $scope.formLoading = false


Controller.tag = "page:auth/login"
Controller.$inject = [
  "$http"
  "$location"
  "$log"
  "$scope"
  "$window"
  "@notifications"
  "@models/session"
]
module.exports = Controller