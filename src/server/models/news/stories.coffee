###*
 * [Promise description]
 *
 * @author Steven Enamakel <me@steven.pw>
###
Promise   = require "bluebird"
validator = require "validator"
markdown  = require("markdown").markdown


exports = module.exports = (BaseModel, Users, Comments, NewsCategories) ->
  # after this many minutes old, a story cannot be edited
  MAX_EDIT_MINS = 90

  # days a story is considered recent, for resubmitting
  RECENT_DAYS = 30


  class Model extends BaseModel
    tableName: "news_stories"

    extends:
      comments: ->
        @hasMany "news_comments", "story"
      categories: ->
        @belongsToMany "news_categories", "news_story_category", "story",
          "category"
      created_by: -> @belongsTo "users", "created_by"
      updated_by: -> @belongsTo "users", "updated_by"


    top: (buildQuery, options={}) ->
      options.order = hotness: "DESC"
      options.withRelated = ["created_by", "categories"]
      @query buildQuery, options


    # Setup the enum types
    enums: categories: tableName: "news_categories"


    calculate_hotness: ->
      base = 0
      # self.tags.select{|t| t.hotness_mod != 0 }.each do |t|
      #   base += t.hotness_mod
      # end

      # Give a story's comment votes some weight, but ignore the story
      # submitter's own comments
      # cpoints = self.comments.where("user_id <> ?", self.user_id).
      #   select(:upvotes, :downvotes).map{|c| c.upvotes + 1 - c.downvotes }.
      #   inject(&:+).to_i
      cpoints = 0

      # don't immediately kill stories at 0 by bumping up score by one
      order = Math.log Math.max(Math.abs(score + 1).abs + cpoints, 1), 10
      if score > 0 then sign = 1
      else if score < 0 then sign = -1
      else sign = 0

      # TODO: as the site grows, shrink this down to 12 or so.
      window = 60 * 60 * 36

      Math.round -((order * sign) + base +
        (Number(@created_at or Date.now()) / window)), 7


    validationURL: (json) ->
      if json.url?
        if not validator.isURL json.url then throw new Error "URL is invalid"
      else if json.description?
        if json.description.strip().length == 0
          throw new Error "must contain description if no URL posted"
      else throw new Error "must contain either description or URL"



    create: (parameters) ->
      categories = parameters.categories or []

      delete parameters.categories

      @model.forge(parameters).save()
      .then (model) =>

        insertQuery = (category: cat, story: model.id for cat in categories)
        @knex("news_story_category").insert(insertQuery).then -> model


    onCreate: (model) ->
      # First set the slug from the right variable.
      model.set "slug", @createSlug model.get "title"

      # Then parse the description if it was set.
      if description = model.get "description"
        model.set "description", markdown.toHTML description


    recent: (options) ->
      options.withRelated = ["created_by", "categories"]
      options.order = created_at: "DESC"
      @model.forge().fetchPage null, options




    comments: (id) ->
      @model.where(id: id).fetch withRelated: ["comments"]
      .then (story) ->
        comments = story.related("comments").load "created_by"
        comments
        # data


    increaseCommentsCount: (id) ->
      @get(id).then (model) ->
        model.set "comments_count", 1 + model.get "comments_count"
        model.save()


    upvote: (story_id, user_id) ->
      @knex("news_votes").insert
        user: user_id
        story: story_id
        is_upvote: true
      .then =>
        @get(story_id).then (model) ->
          model.set "upvotes", 1 + model.get "upvotes"
          model.set "hotness", Math.random * 10 * model.get "upvotes"
          # calculate_hotness
          model.save()


    isRecent: (json) -> json.created_at >= RECENT_DAYS.days.ago #fix this

  new Model


exports["@singleton"] = true
exports["@require"] = [
  "models/base/model"
  "models/users"
  "models/comments"
  "models/news/categories"
]
