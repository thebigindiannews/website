jade = require "jade"
_    = require "underscore"


###
A helper module which returns a function used to render the page properly with
the right parameters and some default values.

This module introduces in-memory cache to avoid having jade to recompile
redundant HTML and also introduces alot of custom variables that are also
exposed to the compiler.

For a better understanding about how to use this module see the documentation
of the function that gets returned below.
###
exports = module.exports = (settings, Cache) ->
  defaults =
    _: global.__
    lang: "en"

    data: {}
    environment: settings.server.env
    settings: settings
    staticUrl: settings.staticUrl
    url: settings.url
    cache: {}

    publicData:
      environment: settings.server.env
      staticUrl: settings.staticUrl
      url: settings.url

    cryptedData:
      sitename: settings.sitename
      google:
        analyticsCode: settings.google.analyticsCode
        clientID: settings.google.clientID
        reCaptchaKey: settings.google.reCaptcha.siteKey


  #! Base64 encode the crypted data key.. (it gets decoded in the client side,
  #! but this just makes sure that bots don't fetch any sensitive info)..
  defaults.cryptedData = (new Buffer(JSON.stringify defaults.cryptedData))
    .toString "base64"


  ###
  TODO: Write this...
  ###
  Middleware = (filePath, options, callback) ->
    #! Setup the cache variables
    cacheKey = "never-set"

    # options = options.customs or {}

    #! If cache is set then setup cache variables, if this was a JSON request
    #! then don't look in the cache. (We cache only rendered HTML)
    if options.cache?
      cacheEnable = true
      cacheKey = "renderer@#{filePath}"
      cacheTimeout = null#options.cache.timeout

    #! Everything has been set so now check the cache for the HTML of this page
    Cache.get cacheKey

    #! If there was nothing found in the cache, then start the compilation
    #! procedures.
    .catch ->
      #! Immediately bail out if we are doing a JSON request.
      if options.json? then return options.data

      #! # Set the language options
      #! options.lang = request.getLocale()
      if options.lang == "ar" then options.dir = "rtl"

      #! Give the default page title if title is undefined. If a title was
      #! defined but set to null, then don't do anything!
      # if options.title == undefined
        # options.title = response.__ "#{options.page}:title"

      #! Setup options for the jade compiler and HTML compiler
      jadeOptions =
        cache: cacheEnable
        pretty: defaults.environment is "development"
      htmlOptions = _.extend defaults, options or {}

      ###
      Set the MD5 variables into the publicData field. We set this value
      here because underscore doesn't support deep extends and the MD5 value
      is something that changes often so it is not recommended keep it in the
      defaults section (which remains static) nor pass it through the options
      ###
      htmlOptions.publicData.md5 = settings.md5 or {}

      viewURL = filePath
      fn = jade.compileFile viewURL, jadeOptions or {}
      html = fn htmlOptions or {}

      ###
      Now that we have compiled the HTML, we decide if we want to cache it or
      not.

      Note that these function return a promise which then resolves to
      the HTML code, so the next promise function will definitely receive
      HTML one way or the other
      ###
      if cacheTimeout? then return Cache.set cacheKey, html, cacheTimeout
      else if cacheEnable then return Cache.set cacheKey, html
      else return html

    #! Finally write to the response!
    .then (data) -> callback null, data


  Middleware

exports["@require"] = [
  "igloo/settings"
  "libraries/cache"
]
exports["@singleton"] = true