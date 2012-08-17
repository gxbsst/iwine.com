class Tag extends Backbone.Model
class Tags extends Backbone.Collection
  url: '/api/event_tags/hot_tags'
  # model: Tag

# class SelectTags extends HotTags
@app = window.app ? {}
@app.Tags= new Tags
# @app.SelectTags = new Tags
    
jQuery ->
  _.templateSettings = {
    interpolate: /\<\@\=(.+?)\@\>/g,
    evaluate: /\<\@(.+?)\@\>/g
  }

  class SelectTagsListView extends Backbone.View
    template: _.template($("#selected_tags_template").html())
    initialize: ->
      _.bindAll(@, 'render')
      @collection.bind 'reset', @render
      @options.hotTags.bind 'select', @addTag
    render: ->
      $(@el).html @template {}
      collection = @collection
      @collection.each (model) ->
        selectTagsView = new SelectTagsView model: model, collection: collection
        @.$('ul').append(selectTagsView.render().el)
      @
    addTag: (tag) ->
      @collection.add(tag)
    
  class HotTagsListView extends Backbone.View
    template: _.template($("#hot_tags_template").html())
    initialize: ->
      _.bindAll(@, 'render')
      @collection.bind 'reset', @render
    render: ->
      $(@el).html @template {}
      collection = @collection
      @collection.each (model) ->
        hotTagsView = new HotTagsView  model:model, collection: collection
        @.$('ul').append(hotTagsView.render().el)
      @
  class TagsView extends Backbone.View
    tagName: 'li'
    template: _.template($("#tags_template").html())
    initialize: ->
      _.bindAll(@, 'render')
    render: ->
      $(@el).html @template @model.toJSON()
      @

  class HotTagsView extends TagsView
    events: {
      'click  a' : 'select'
    }
    initialize: ->
      _.bindAll(@, 'render')
    select: ->
      @collection.trigger('select', @model)

  class SelectTagsView extends TagsView
    events: {
      'click a' : 'removeFromSelected'
    }
    initialize: ->
      _.bindAll(@, 'render')
      @collection.bind('reset', @render);

    removeFromSelected: ->
      @options.hottags.remove(@model)

   class EventAppView extends Backbone.View
     initialize: ->
       _.bindAll(@,'render')
       @hotTags =  @options.hotTags
       @hotTags.fetch()
       @selectTags = @options.selectTags
     render: ->
       hotTagsListView = new HotTagsListView collection: @hotTags
       $("#hot_tags_container").append(hotTagsListView.render().el)
       selectTagsListView = new SelectTagsListView collection: @selectTags, hotTags: @hotTags
       $("#select_tags_container").append(selectTagsListView.render().el)
       @
       
   @app = window.app ? {} 
   hotTags = @app.HotTags
   selectTags = @app.SelectTags
   @app.EventAppView = new EventAppView hotTags: hotTags, selectTags: selectTags
   @app.EventAppView.render()
  
  # class EventView extends Backbone.View
    # el: "#event_form"
    # initialize: (options) ->
      # @collection.bind 'reset', @render, @
    # render: ->
      # $(@el).empty()
      # $(@el).append  @subview
 

