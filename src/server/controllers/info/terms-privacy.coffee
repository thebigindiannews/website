exports = module.exports = ->
  controller: (request, response, next) ->
    response.render "main/info/terms-privacy", cache: enable: true


exports["@singleton"] = true