# # News Category Model
#
# Creates the enum model for the categories. This model extends the BaseModel.
Model = (BaseModel) ->
  new class CategoryModel extends BaseModel
    tableName: "news_categories"
    full_cache: true

    # ## getStoryCount()
    #
    # Gets the count of stories for each categories.
    getStoryCount: ->
      @knex.select("category").from "news_story_category"
      .count("* as stories").groupBy "category"


Model["@singleton"] = true
Model["@require"] = ["models/base/model"]
module.exports = Model