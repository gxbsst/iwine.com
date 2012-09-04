class Wine extends Backbone.Model
class Wines extends Backbone.Collection
  url: '/searches/wine.json?word=' 
  origin_url: '/searches/wine.json?word=' 
  model: Wine

@app = window.app ? {}
@app.SearchWines = new Wines
@app.SelectWines = new Wines
@app.Wine = Wine
## Add Wine
jQuery ->
  _.templateSettings = {
    interpolate: /\<\@\=(.+?)\@\>/g,
    evaluate: /\<\@(.+?)\@\>/g
  }
  class WineView extends Backbone.View
    setValueOfWineDetailIds: (collection) ->
      $("#wine_detail_ids").val(collection.pluck('wine_detail_id').join(","))
  class SearchWineView extends WineView
    template: _.template($("#search_wine_template").html())
    initialize: ->
      _.bindAll(@, 'render')
    render: ->
      $(@el).html @template @model.toJSON()
      @
    events:
      "click .select": 'select'
    select: (event) ->
      event.preventDefault
      year = parseInt($(event.target).html())
      wine_detail_id = $(event.target).attr('data-value')
      newModel = @model.clone()
      newModel.set('year', year)
      newModel.set('wine_detail_id', wine_detail_id)
      @collection.trigger 'select', newModel

  class SelectWineView extends WineView 
    tagName: 'dl'
    template: _.template($("#select_wine_template").html())
    initialize: ->
      _.bindAll @, 'render', 'remove'
      @model.bind 'remove', @remove
    render: ->
      $(@el).html @template @model.toJSON()
      @
    events:
      'click .remove': 'removeFromSelectList'
    removeFromSelectList: ->
      @collection.remove @model
      @setValueOfWineDetailIds(@collection)
      $('.wine_select').effect("highlight", {}, 3000)


  class SearchWineListView extends Backbone.View
    template: _.template($("#search_wine_list_template").html())
    initialize: ->
      _.bindAll @, 'render'
      @collection.bind('reset', @render)
    render: ->
      $(@el).html @template {}
      if @collection.length > 0
        # @.$('.wines').html('无')
      # else
        @.$('.wines').empty()
        @collection.each (model) =>
          view = new SearchWineView model:model, collection:@collection
          @.$('.wines').append view.render().el
      @

  class SelectWineListView extends Backbone.View
    template: _.template($("#select_wine_list_template").html())
    initialize: ->
      _.bindAll(@, 'render', 'addWine')
      @collection.bind('reset', @render)
      @collection.bind('add', @render)
      @options.wines.bind 'select',  @addWine
    render: ->
      $(@el).html @template {}
      if @collection.length > 0
        @.$('.wines').empty()
        @collection.each (model) =>
          view = new SelectWineView model:model, collection: @collection
          @.$('.wines').append view.render().el
        @showSubmitButton()
      @
    events: 
      'click .save_button': 'submitForm'
    submitForm: (event) ->
      event.preventDefault
      if @collection.length == 0
        alert('请选择酒款...')
      else
        $('#new_event_wine').submit()
    showSubmitButton: ->
      $('.btn_submit').show()
      @.$('.save_button').live ('click'), (event) =>
        @submitForm(event)
        # $('#new_event_wine').submit()
    addWine: (wine) ->
     items =  @collection.where year:wine.get('year'), origin_name: wine.get('origin_name')
     if items.length == 0
       @collection.add(wine)
       wineView = new WineView
       wineView.setValueOfWineDetailIds(@collection)
       $('.wine_select').effect("highlight", {}, 3000)

     else
       alert("这支酒已经添加了")
  class InputSearchView extends Backbone.View
    el: $("#search_input_view")
    events: 
      'keypress input': 'searchWine'
      'click .search_wine_button': 'searchWine'
      'focusout input': 'hideWarning'
    searchWine:(event) ->
      if (event.keyCode is 13 || $(event.target).text() == '搜索') # ENTER
        event.preventDefault()
        name = $(@el).find('input').val()
        if name.trim() == ''
          @flashWarning '', "请输入酒名"
        else
          @showLoading()
          wines = window.app.SearchWines
          wines.url = wines.origin_url + name 
          wines.fetch success: =>
            @hideLoading()
            @showSearchResult()
            @showSelectResult()
            @showSelectWineTips()
    showSearchResult: ->
      $("#result_container .search_result").empty()
      $("#result_container .search_result").append(window.app.SearchWineListView.render().el)
    showSelectResult: ->
      $("#result_container .select_result").empty()
      $("#result_container .select_result").append(window.app.SelectWineListView.render().el)
    focus: ->
      $(@el).find('input').val('').focus()
    hideWarning: ->
      $('#warning').hide()
    flashWarning: (model, error) =>
      console.log error
      $('#warning').html(error).fadeOut(100)
      $('#warning').fadeIn(400)
    showLoading: ->
      $(@el).find('.loading').show()
      $('.search_result .loading_l').show()
    hideLoading: ->
      $(@el).find('.loading').hide()
      $('.search_result .loading_l').hide()
    showSelectWineTips: ->
      title = '<div class="float_r"><span class="notice_b">这些都不是您要找的酒？</span><a href="/wines/new" class="btn_gray"><span>添加酒款</span></a></div>'
      tips = '<p class="notice_b">我们为您搜寻到以下酒款<span class="red">（请单击年份以选择酒款）</span></p>'
      $('.top_text').append(title)
      $('.top_text').append(tips)


  @app = window.app ? {}
  @app.InputSearchView = new InputSearchView
  # @app.SelectWineListView = SelectWineListView
  @app.SelectWineListView = new SelectWineListView collection: window.app.SelectWines, wines:window.app.SearchWines
  $("#result_container .select_result").append(@app.SelectWineListView.render().el)
  @app.SearchWineListView = new SearchWineListView collection: window.app.SearchWines
  $("#result_container .search_result").append(@app.SearchWineListView.render().el)
  
