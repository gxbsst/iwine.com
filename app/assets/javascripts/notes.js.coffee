class window.Trait extends Backbone.Model
  defaults: {
  "select":  "",
  "image": ""
  }

  markSelect: ->
    if @.get('select') == undefined || @.get('select') == ""
      @.set({'select': 'rg'})
    else
      @.set({'select': ''})

class window.Traits extends Backbone.Collection
  model: window.Trait
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
      debugger
      $(@tagName).css('overflow', 'auto');
      @
    initialize: ->
      _.bindAll(@, 'render')
      @model.on('change', @render, @)
    events:
          'click li p a': 'select'
    select: ->
      @model.markSelect()

  class window.TraitListView extends Backbone.View
    template: _.template($('#trait_list_template').html())
    initialize: ->
      _.bindAll(@, 'render')
    render: ->
      $(@el).html @template {}
      @collection.forEach (model) =>
       traitItemView = new TraitItemView  model:model
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
          v = new TraitListView({collection: @collection})
        else
          v = new TraitListView({collection: result})
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
        debugger
        if value == ''
          result = @collection
        else
          result = @collection.search(value)
        v = new TraitListView({collection: result})
        v.render()

  class window.NoteAppView extends Backbone.View
    el: "#comment_form"
    initialize: ->
      @.options.sidebarView = new window.SideBarView({collection: @collection})
      @.options.traitListView = new window.TraitListView({collection: @collection})
      @.options.SearchView = new window.SearchView({collection: @collection})
    render: ->
      @.options.traitListView.render()
