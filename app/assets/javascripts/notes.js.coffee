# =====================================================
#* Backbone Js  添加品酒辞的颜色/风味特征
#*    by Weston, 20th NOV 2012
#* ------------------------------
#* Usage:
#* 1. 先在模板添加， 参考: note/edit_seond_html.erb
# 2.如下为颜色， 但要注意： link 的参数和 ID
    # <%= hidden_field_tag :color, '', :id => 'select_color_input' %>
    #<%= link_to color_notes_path(:model => 'color'), :remote => true, :class => "btn_gray", :id => :select_color do %>
    #<span>选择颜色</span>
    #<% end %>
    #</p>
    #<ul class="feature" id="color_outer">
    #
    #</ul>
#  3. 参考 notes_controller 的 action 及 wine_color model 要处理 已经选择的部分
#  4. 注意设置 NoteAppView 的 el
#  5. 运行
#$(document).ready(function(){
#var _ref, collection, sidebarView, traitListView;
#  window.app = (_ref = window.app) != null ? _ref : {};
#  collection = new window.Traits(JSON.parse($('#json').html()));
#  window.app.noteAppView = new NoteAppView({ collection: collection, forModel: $('#for_model').html()  });
#  window.app.noteAppView.render();
#});
#* =====================================================
#

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
      @model.bind('change', @render, @)
      @model.bind('destroy', @remove, @)

    events:
          'click li p a': 'select'
    select: ->
      # 如果是颜色，只能单选
      if @options.forModel == 'color'
        @model.collection.cancleAllSelected()
      @model.markSelect()

  class window.TraitItemDisplayView extends window.TraitItemView
    template: _.template($("#trait_item_display_template").html())

    events:
        'click a.remove': 'remove'

    remove: ->
      @model.cancleSelect()
      $(@.el).remove()
      n = new window.NoteAppView collection: @model.collection, forModel: @options.forModel
      n.save()
#      selectLink = '#select_' + @options.forModel
#      n.addParamsToUrl(@model.collection, selectLink)

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
      outer = "#" + @options.forModel + '_' + 'outer'
      $(outer).html('')
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
      pathname = $(element)[0].pathname
      href = pathname + params_text + for_model
      $(element).attr('href', href)

    renderItem: (result, element) ->
      $(element).html('')
      result.forEach (model) =>
        traitItemView = new window.TraitItemDisplayView  model:model, forModel: @options.forModel
        $(element).append(traitItemView.render().el)

    fillInput: (element, result) ->
      a = []
      a.push item.get 'key' for item in result
      $(element).attr 'value', a.join(";")






