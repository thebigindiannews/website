exports = module.exports = (Story, Comments) ->
  controller = (request, response, next) ->
    request.body.created_by = request.user.id

    Comments.create request.params[0], request.body
    .then (comment) -> response.json comment
    .catch (e) -> next e


exports["@require"] = [
  "models/news/stories"
  "models/news/comments"
]
exports["@singleton"] = true
