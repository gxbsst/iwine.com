class Friend extends Backbone.Model
class Friends extends Backbone.Collection
  url: '/api/users/friends'

@app = window.app ? {}
@app.Friends = new Friends
@app.Friend = Friend
@app.SelectFriends = new Friends

jQuery ->
  _.templateSettings = {
    interpolate: /\<\@\=(.+?)\@\>/g,
    evaluate: /\<\@(.+?)\@\>/g
  }

  class FriendView extends Backbone.View
    'el': $('form#new_event_invitee')
    'events':
      'click ul.userlist2 .userpic' : 'toggleSelect'
      'click ul .select input' : 'toggleSelect'
      'click input#select_all' : 'selectAll'
      'click a#submit_form' : 'submitForm'

    initialize: ->
      _.bindAll(@, 'render')

    render: ->
      all_checkbox = @.$('.select input')
      all_checkbox.each ->
        $(@).prop('checked', false)
      @collection.each (user) =>
       $("#user_" + user.id).prop('checked', true)
      @
    selectAll:(event) ->
      @options.alluser.fetch success: =>
        checkbox = $(event.target)
        if checkbox.is(':checked')
          @options.alluser.each (model) =>
            model = new window.app.Friend id:model.id
            @collection.add model
        else
          @options.alluser.each (model) =>
            model = new window.app.Friend id:model.id
            @collection.remove model
        @render()

    toggleSelect:(event) ->
      $("input#select_all").prop('checked', false)

      if event.target.tagName == 'INPUT'
        checkbox = $(event.target)
        user_id = checkbox.val()
        if checkbox.is(':checked')
          model = new window.app.Friend id:user_id
          @collection.add model
        else
          model = new window.app.Friend id:user_id
          @collection.remove model
      else
        event.preventDefault()
        checkbox = $(event.target).parentsUntil('ul').find(".select input")
        user_id = checkbox.val()
        if checkbox.is(':checked')
          checkbox.prop("checked", false)
          model = new window.app.Friend id:user_id
          @collection.remove model
        else
          checkbox.prop('checked', true)
          model = new window.app.Friend id:user_id
          @collection.add model

    submitForm: (event) ->
      if @collection.length < 1
        alert("请选择您要邀请的好友")
      else
        @el.submit()

  @app = window.app ? {}
  @app.FriendView = new FriendView collection: window.app.SelectFriends, alluser: window.app.Friends
