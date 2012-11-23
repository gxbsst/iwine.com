class window.Trait extends Backbone.Model
  defaults: {
  "select":  "",
  "image": ""
  }

  markSelect: ->
    if @.get('select') == undefined || @.get('select') == "" || @.get('select') == null
      @.set({'select': 'rg'})
    else
      @cancleSelect()

  cancleSelect: ->
    @.set({'select': ''})

class window.Traits extends Backbone.Collection
  model: window.Trait

  # 颜色是单选
  cancleAllSelected: ->
    @.forEach (model) =>
      model.cancleSelect()

  search: (word) ->
    pattern = new RegExp(word, 'i' )
    @.filter (t) =>
      (pattern.test t.get('name_en')) || (pattern.test t.get('name_zh'))


jQuery ->
  _.templateSettings = {
  interpolate: /\<\@\=(.+?)\@\>/g,
  evaluate: /\<\@(.+?)\@\>/g
  }

  class window.TraitItemView extends Backbone.View
    tagName: 'li'
    template: _.template($("#trait_item_template").html())
    render: ->
      $(@el).html @template @model.toJSON()
      $(@tagName).css('overflow', 'auto');
      @
    initialize: ->
      _.bindAll(@, 'render')
      debugger
      @model.bind('change', @render, @)
    events:
          'click li p a': 'select'
    select: ->
      # 如果是颜色，只能单选
      if @options.forModel == 'color'
        @model.collection.cancleAllSelected()
      @model.markSelect()

  class window.TraitItemDisplayView extends window.TraitItemView
    template: _.template($("#trait_item_display_template").html())


  class window.TraitListView extends Backbone.View
    template: _.template($('#trait_list_template').html())
    initialize: ->
      _.bindAll(@, 'render')
    render: ->
      $(@el).html @template {}
      @collection.forEach (model) =>
       traitItemView = new TraitItemView  model:model, forModel: @options.forModel
       @.$('ul').append(traitItemView.render().el)
      $("#traits_container").html(@el)
      @

  class window.SideBarView extends Backbone.View
      el: '#feature_catalog'
      events:
        'click li a': 'reloadTraits'
      reloadTraits: (event) ->
        e = event.target
        @toggleClassName(e)
        parent_id = parseInt(e.getAttribute('data-value'))
        result = @collection.where({parent_id: parent_id})
        if parent_id == 0
          v = new TraitListView({collection: @collection, forModel:@options.forModel})
        else
          v = new TraitListView({collection: result, forModel:@options.forModel})
        v.render()
      toggleClassName: (e) ->
        _.each @.$("li"), (li) =>
          $(li).removeClass('current')
        $(e.parentNode).addClass('current')

  class window.SearchView extends Backbone.View
    el: '#search_trait'
    events:
      'click #search_trait_button': 'search'
      'keypress #search_trait_input': 'search'
    search: (event) ->
      if (event.keyCode is 13 || $(event.target).attr('id') == 'search_trait_button') # ENTER
        value = @.$('#search_trait_input').val()
        if value == ''
          result = @collection
        else
          result = @collection.search(value)
        debugger
        v = new TraitListView({collection: result, forModel: @options.forModel}).render()


  class window.NoteAppView extends Backbone.View
    el: "#comment_form"
    events:
      'click #save_button .btn_gray_b': 'save'
    initialize: ->
      @.options.sidebarView = new window.SideBarView({collection: @collection, forModel: @options.forModel})
      @.options.traitListView = new window.TraitListView({collection: @collection, forModel: @options.forModel})
      @.options.SearchView = new window.SearchView({collection: @collection, forModel: @options.forModel})
    render: ->
      @.options.traitListView.render()

    save: ->
      $(outer).html('')

      outer = "#" + @options.forModel + '_' + 'outer'
      selectLink = '#select_' + @options.forModel
      input = selectLink + '_input'

      $.fancybox.close()

      result = @collection.where({select: 'rg'})
      @addParamsToUrl(result, selectLink)
      @fillInput(input, result)
      @renderItem(result, outer)

    addParamsToUrl: (params, element) ->
      ids = params.map (p) ->
        p.get('id')
      for_model = '&model=' + @.options.forModel
      params_text = "?ids=" + ids.join(',')
      debugger
      pathname = $(element)[0].pathname
      href = pathname + params_text + for_model
      $(element).attr('href', href)

    renderItem: (result, element) ->
      result.forEach (model) =>
        traitItemView = new window.TraitItemDisplayView  model:model
        $(element).append(traitItemView.render().el)

    fillInput: (element, result) ->
      a = []
      a.push item.get 'key' for item in result
      debugger
      $(element).attr 'value', a.join(";")






