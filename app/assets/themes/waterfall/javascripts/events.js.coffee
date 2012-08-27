class Tag extends Backbone.Model
  validate: (attributes) ->
    # NOTE: attributes argument is ONLY the ones that changed.
    mergedAttributes = _.extend(_.clone(@attributes), attributes)
    if !mergedAttributes.name or mergedAttributes.name.trim() == ''
      return "Task title must not be blank."

class Tags extends Backbone.Collection
  url: '/api/event_tags/hot_tags'
  model: Tag

class Wines extends Backbone.Collection
  url: '/searchs/wine?word=' 

# class SelectTags extends HotTags
@app = window.app ? {}
@app.Tag = Tag
@app.HotTags= new Tags
@app.SelectTags = new Tags
@app.SearchWines = new Wines
@app.SelectWines = new Wines
    
jQuery ->
  _.templateSettings = {
    interpolate: /\<\@\=(.+?)\@\>/g,
    evaluate: /\<\@(.+?)\@\>/g
  }

  class SelectTagsListView extends Backbone.View
    template: _.template($("#selected_tags_template").html())
    initialize: ->
      _.bindAll(@, 'render', 'addTag')
      @collection.bind 'reset', @render
      @collection.bind 'add', @render
      @options.hotTags.bind 'select', @addTag
    render: =>
      $("#event_tag_list").val(@collection.pluck('name').join(","))
      $(@el).html @template {}
      @collection.each (model) =>
        selectTagsView = new SelectTagsView model: model, selectTags: @collection
        @.$('ul').append(selectTagsView.render().el)
      $("#select_tags_container").append(@el)
      @
    addTag: (tag) ->
      # 如果已经选择，则不再添加
      if (@collection.where name: tag.get('name')).length == 0
        @collection.add(tag)
      else
        alert('该标签已经添加了')
        # window.app.InputTagView.flashWarning "", "已经添加了"
    
  class HotTagsListView extends Backbone.View
    template: _.template($("#hot_tags_template").html())
    initialize: ->
      _.bindAll(@, 'render')
      @collection.bind 'add', @render
      @collection.bind 'reset', @render
    render: ->
      $(@el).html @template {}
      @collection.each (model) =>
        hotTagsView = new HotTagsView  model:model, collection: @collection
        @.$('ul').append(hotTagsView.render().el)
      $("#hot_tags_container").append(@el) 
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
    events: 
      'click a' : 'removeFromSelected'
    initialize: ->
      _.bindAll(@, 'render', 'remove')
      @model.bind 'remove', @remove

    removeFromSelected: ->
      @options.selectTags.remove(@model)
      $("#event_tag_list").val(@options.selectTags.pluck('name').join(","))

  class InputTagView extends Backbone.View
    el: $("#input_tag_view")
    events: 
      'keypress input': 'addTag'
      'focusout input': 'hideWarning'
    addTag:(event) ->
      if (event.keyCode is 13) # ENTER
        event.preventDefault()
        name = $(@el).find('input').val()
        if name.trim() == ''
          @flashWarning '', "不能为空"
        else
          newTag = new window.app.Tag({name:name})
          # newAttributes = {name: $(@el).find('input').val()}
          errorCallback = {error:@flashWarning}
          # 如果已经选择，则不再添加
          if (@collection.where name:name).length == 0 
            if @collection.add(newTag, errorCallback)
              @hideWarning()
              @focus()
          else
            alert('该标签已经添加了')
            # @flashWarning '', "已经添加了"
    focus: ->
      $(@el).find('input').val('').focus()
    hideWarning: ->
      $('#warning').hide()
    flashWarning: (model, error) =>
      console.log error
      $('#warning').html(error).fadeOut(100)
      $('#warning').fadeIn(400)
  class EventAppView extends Backbone.View
    el: $('.whitespace')
    events: 
      'click #button_add_wines': 'submit'
      'click #submits .publish': 'update_status_as_publish'
      'click #submits .not_publish': 'update_status_as_draft'
      'click #submits .cancle': 'update_status_as_cancle'
      'click .save_event_button': 'submit'
    update_status_as_publish: (event) ->
     @.$("#event_publish_status").val(2) # published 
     @submit()
    update_status_as_draft: (event) ->
     @.$("#event_publish_status").val(1) # draft 
     @submit()
    update_status_as_cancle: (event) ->
     @.$("#event_publish_status").val(0) # cancle
     @submit()

    submit: ->
      if @options.selectTags.length == 0 
        alert("请输入活动标签")
      else
        @.$('#form').submit()
 
  @app = window.app ? {}
  # Tags
  @app.HotTagsListView =  HotTagsListView
  @app.SelectTagsListView = SelectTagsListView
  @app.InputTagView = InputTagView 

  @app.EventAppView = new EventAppView selectTags: window.app.SelectTags
