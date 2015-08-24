###
This file is mainly responsible for setting up all the different routes for
the App. You'll find routes for the the non-api controllers defined here.

The routes for the files are not listed here, but rather the controller folder
is recursively walked and the controllers are picked up and set with the
routes defined in them. If you want to know which controller gets called on
which route then either
  - watch the console.debug for statements about controller and route
    assignments
  - go through each file inside of the controller folder and find the route
    that matches the url you are looking for.
###
Express   = require "express"
Walk      = require "fs-walk"
path     = require "path"


exports = module.exports = (IoC) ->
  app = this
  router = Express.Router()
  logger = IoC.create "igloo/logger"

  ###
  Function to properly set the language based on the language slug. This
  function acts more as a custom middleware.

  *TODO: This function is not implemented as we don't really have i18n support
  yet.*
  ###
  setLanguage = (request, response, next) ->
    # If the language cookie was not set, then set it.
    if not request.cookies["l"] then response.cookie "l", request.getLocale()
    # Read the cookies which sets the language.
    else response.setLocale request.cookies["l"]
    # Goto the next middleware.
    next()


  ###
  **_route()** This helper function shortens the long line of writings routes
  and calls the dependency injector.

  Modify this if you want to customize how routes and controllers get added.
  ###
  _route = (url, controller) ->
    #! If a string was passed to us, then we instansiate the controller
    #! manually.
    if typeof controller is "string" then controller = getController controller

    #! This url matcher will take care of trailing back-slashes. Modify this
    #! if you want to add a prefix.
    urlRegex = new RegExp "^#{url}/?$"

    #! Finally add the route to Express's router! `controller.controller` will
    #! refer to the controller function specified in the controller file.
    router.get urlRegex, controller.controller


  ###
  **getController()** This function fetches the controller given it's name.

  Modify this function if you want to customize where the controller are
  located. IoC's loader knows where the contrller are because of the
  ```
    IoC.loader "controllers", _library "controllers"
  ```
  line in the [app.coffee](../app.coffee) file.

  ###
  getController = (name) -> IoC.create "controllers/#{name}"


  ###
  **isController()** This function is used to determine if a given filename
  is a valid controller (for us to instantiate and add to the route) or not.

  This function's main responsiblity is to filter out test files and files
  not ending with '.coffee'.
  ###
  isController = (fn) -> fn.indexOf("test") is -1 and /coffee$/.test(fn)


  #! Now start walking!
  walkPath = path.join __dirname, "../controllers"
  Walk.walkSync walkPath, (basedir, filename, stat) ->
    #! If the filename does not match the rules for a controller then we skip.
    if not isController filename then return

    #! Now we get the proper controller name from which we can pass on to IoC.
    file = path.join basedir, filename.split(".coffee")[0]
    relativePath = path.relative walkPath, file

    #! Invoke IoC and get an instance of our controller
    controller = getController relativePath

    #! Now if this controller does not have any routes then we skip it!
    if not controller.routes? then return

    #! If it did have routes set, then we set it for each of its routes
    for route in controller.routes
      _route route, controller

      if route == "" then route = "/"
      logger.debug "GET\t#{route} -> #{relativePath}"


  #! If none of the routes matched, then route to the 404 controller!
  _route ".*",                                     "errors/404"

  #! Finally attach the router into the app
  app.use router


exports["@require"] = ["$container"]
exports["@singleton"] = true