
class AutoCompeteCollection extends Backbone.Collection
  url: '/api/event_tags/index'
  # constructor: (url) ->
    # @url = url

@app = window.app ? {}
@app.AutoCompeteCollection = new AutoCompeteCollection 

jQuery ->

  _.templateSettings = {
    interpolate: /\<\@\=(.+?)\@\>/g,
    evaluate: /\<\@(.+?)\@\>/g
  }

  class AutoCompleteItemView extends Backbone.View

    tag: 'li'

    template: _.template($('#auto_compleate_view').html())

    initialize: ->
      _.bindAll(@, 'render')
      # @initializeTemplate
    events: {
      "click  a" : "selectRegion"
    }

    # initializeTemplate: ->
      # @templateSource = _.template (($ @template).html())

    render: ->
      $(@el).html @template @model.toJSON()
      @

    selectRegion: (event) ->
      target = event.target
      @setInputText target.text
      console.log $(target).attr('data-value')

    setInputText: (text) ->
      console.log(@options.inputView)

  class AutoCompleteSelectItemView extends AutoCompleteItemView

  class AutoCompleteHotItemView extends AutoCompleteItemView
  
  class AutoCompeteInputView extends Backbone.View
    el: $('#query_outer')
    events: {
      "keyup input" : "showResource"
    }
    showResource: (event) ->
      console.log "aaa"
      self = @
      str = $(@el).find('input').val()
      # if str.length > 2
      origin_url = self.collection.url
      self.collection.url = origin_url + "?query=" + str
      self.collection.fetch (success: -> 
        self.renderResource self.collection)
    
    renderResource: (collections) ->
      showResourceContainer = $(@options.resourceContainer)
      showResourceContainer.empty()
      self = @
      collections.each (model) ->
        autoCompleteItemView = new AutoCompleteItemView model: model, inputView: self
        showResourceContainer.append autoCompleteItemView.render().el

    countText: (event) ->
      @showError('')
      @showSuccess('')
      str = $(@el).find('textarea').val()
      if str == ""
        return
      @strCount = @getStrleng str

    getStrleng: (str) -> 
       pattern = new RegExp(
          '[A-Za-z0-9_\]+|'+                             # ASCII letters (no accents)
          '[\u3040-\u309F]+|'+                           # Hiragana
          '[\u30A0-\u30FF]+|'+                           # Katakana
          '[\u4E00-\u9FFF\uF900-\uFAFF\u3400-\u4DBF]',   # Single CJK ideographs
          'g')
       nwords = str.match(pattern).length
       nwords

  @app = window.app ? {}
  params = {
    el: $('#auto_complete_input_view'), 
    resourceContainer:  "#resource_container",
    collection: app.AutoCompeteCollection 
  }
  @app.AutoCompeteInputView =  new AutoCompeteInputView params
  @app.AutoCompleteItemView = new AutoCompleteItemView  


