Router = ($stateProvider, $locationProvider, $urlMatcher, $urlRouterProvider) ->
  # Disable strict mode to allow URLs with trailing slashes
  $urlMatcher.strictMode false

  # Helper function to create our routes
  index = 0
  _route = (page, route) ->
    templateUrl = "views/#{page}/template"
    $stateProvider.state "#{page}-#{index++}",
      controller: page
      page: page
      templateUrl: templateUrl
      url: route
      resolve:
        user:       ["@models/users",           (m) -> m.download()]
        language:   ["@models/languages",       (m) -> m.download()]


  #! Start adding each route one by one
  _route "auth/login",         "/login"
  _route "auth/logout",        "/logout"
  _route "auth/login",         "/login/forgot"
  _route "auth/signup",        "/signup"

  _route "info/about",         "/info/about"
  _route "info/contribute",    "/info/contribute"
  _route "info/terms-privacy", "/info/terms-privacy"

  _route "news/index",         ""
  _route "news/settings",      "/settings"
  _route "news/index",         "/page/{page:[0-9]+}"

  _route "news/recent",        "/comments"
  _route "news/recent",        "/comments/page/{page:[0-9]+}"

  _route "news/recent",        "/recent"
  _route "news/recent",        "/recent/page/{page:[0-9]+}"
  _route "news/search",        "/search"
  _route "news/single",        "/story/{story:[^/]+}"
  _route "news/submit",        "/submit"

  _route "error/404",         "*page"


  #! Enable HTML5 pushstate for hash-less URLs
  $locationProvider.html5Mode
    enabled: true
    requireBases: false


Router.$inject = [
  "$stateProvider"
  "$locationProvider"
  "$urlMatcherFactoryProvider"
  "$urlRouterProvider"
]
module.exports = Router