Ouch = require "ouch"

Controller = module.exports = (settings) ->
  ouchInstance = (new Ouch).pushHandler (
    new (Ouch.handlers.PrettyPageHandler)('orange', null, 'sublime'))

  (error, request, response, next) ->
    response.status error.status or 500
    isProduction = settings.server.env == "production"

    #! In production, no stack-traces leaked to user
    if isProduction then error.stack = null

    #! In development, display the error on console
    else console.error error

    #! For API request just return a JSON version of the message
    if request.url.indexOf("/api") > -1
      return response.json error: error.message



    ouchInstance.handleException error, request, response, (output) ->
      console.log 'Error handled properly'


    # response.render "main/errors/5XX",
    #   page: "errors/5XX"
    #   title: "Something freaky happened!"
    #   data:
    #     error: error
    #     message: error.message
    #     status: error.status or 500


Controller["@require"] = ["igloo/settings"]
Controller["@singleton"] = true