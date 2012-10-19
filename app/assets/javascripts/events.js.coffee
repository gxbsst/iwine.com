class Tag extends Backbone.Model
  updateSelectStatus: ->
    @.set select: 'select'
  validate: (attributes) ->
    # NOTE: attributes argument is ONLY the ones that changed.
    mergedAttributes = _.extend(_.clone(@attributes), attributes)
    if !mergedAttributes.name or mergedAttributes.name.trim() == ''
      return "Task title must not be blank."

class Tags extends Backbone.Collection
  url: '/api/event_tags/hot_tags'
  model: Tag
  updateSelectStatusByName: (name) ->
    tags = @.where name: name
    if tags.length > 0
      tags.forEach (tag) ->
        tag.updateSelectStatus()

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
  class HotTagsListView extends Backbone.View
    template: _.template($("#hot_tags_template").html())
    initialize: ->
      _.bindAll(@, 'render', 'addTag')
      @collection.bind 'reset', @render
      @options.selectTags.bind 'remove', @render
      @options.selectTags.bind 'add', @render
      @collection.bind 'select', @addTag
      @collection.on 'update_status', @render
    addTag: (tag) ->
      @options.selectTags.on 'add', @render
      selectTagItem = @options.selectTags.where name:tag.get('name')
      if selectTagItem.length > 0
        tag.set select: ''
        @options.selectTags.remove(selectTagItem)
      else
        if @options.selectTags.length < 5
          tag.set select: 'select'
          @options.selectTags.add(tag)
        else
          alert("最多可添加5个标签")
    render: ->
      $(@el).html @template {}
      selectTags = @options.selectTags
      if selectTags.length > 0 # 更新collection的select状态
        @updateCollectionSelectStatus(@collection, selectTags)
      @collection.each (model) =>
        hotTagsView = new HotTagsView  model:model, collection: @collection, selectTags: @options.selectTags
        @.$('ul').append(hotTagsView.render().el)
      $("#hot_tags_container").append(@el) 
      @
    updateCollectionSelectStatus: (hotTags, selectTags) -> # 更新collection为select
      hotTags.forEach (tag) ->
        tag.set select: ''
      selectTags.each (selectTag) ->
        items = hotTags.where name: selectTag.get('name')
        if items.length > 0
          items.forEach (item) ->
           item.updateSelectStatus()

  class TagsView extends Backbone.View
    tagName: 'li'
    template: _.template($("#tags_template").html())
    initialize: ->
      _.bindAll(@, 'render')
    render: ->
      if @model.get('select') == 'select'
        $(@el).addClass('select')
      $(@el).html @template @model.toJSON()
      @

  class HotTagsView extends TagsView
    events: {
      'click  a' : 'select' # 单击某个标签
    }
    initialize: ->
      _.bindAll(@, 'render')
    select: ->
      @collection.trigger('select', @model)

  class InputTagView extends Backbone.View
    el: $("#input_tag_view")
    events:
      "keyup input": 'updateHotTagsSelectStatus'
    updateHotTagsSelectStatus: (event) ->
      @collection.off('add')
      @collection.reset()
      value = @.$('input').val().replace(/；/g, ";")
      # debugger
      if value.trim() != ''
        value.split(';').forEach (tagName) =>
          if tagName.trim() != ''
            tag = new window.app.Tag name: tagName, select: 'select'
            console.info(@collection.length)
            if @collection.length > 4
              alert("最多可添加5个标签")
            else
              @collection.add tag
      @options.hotTags.trigger('update_status')
      $("#event_tag_list").val(@collection.pluck('name').join(","))
    initialize: ->
      @collection.bind('add', @renderInputValue , @)
      @collection.bind('remove', @renderInputValue , @)
      @options.hotTags.bind('select', @renderInputValue, @)
    renderInputValue: ->
      $("#event_tags").val(@collection.pluck('name').join(";"))
      $("#event_tag_list").val(@collection.pluck('name').join(","))


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
    checkBeginEndAt: ->
      begin_at = new Date($('#event_begin_at').val())
      end_at = new Date($('#event_end_at').val())
      if begin_at > end_at
        true 
      else
        false
    flashError: (element, error) ->
      $(element).html(error)
    submit: ->
      if @options.selectTags.length == 0 
        @flashError('#tags_error', '请输入或选取活动标签')
      else if @checkBeginEndAt()
        @flashError('#begin_end_end_at_error', '结束时间不能小于开始时间')
      else
        @.$('#form').submit()
 
  @app = window.app ? {}
  # Tags
  @app.HotTagsListView =  HotTagsListView
  @app.InputTagView = InputTagView 

  @app.EventAppView = new EventAppView selectTags: window.app.SelectTags
