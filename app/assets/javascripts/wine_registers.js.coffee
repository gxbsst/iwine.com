
$ ->
    class Variety extends Backbone.Model

#        defaults: ->
#            name: '1',
#            percentage: '2'


#    class VarietiesCe extends Backbone.Collection
#        #  url: '/api/varieties'
#        model: Variety
##        localStorage: new Store("todos")


    class Varieties extends Backbone.View
#        template: _.template( $("#variety").html() )
##        template: window.JST['entries/index']
#        el: $('#c')
#
#        events:
#            'click #create_variety': 'addOne'

        initialize: ->
#            @input = @$("#new_variety")
#            $(@el).html('TTTT')
#            alert('...')
#            _.bindAll(this, 'render')
#            console.log('here is init')
            _.bindAll(this, "render")
            @render
            this

#           @render

        render: ->
            console.log('here render go')
#            $(@el).html('TTTT')
            this

#        addOne: (variety) ->
#            view = new VarietiesItem()
#            $("#variety_items").append(view.render().el)


#    class VarietiesItem extends Backbone.View
##        template: JST['varieties/varieties_item']
#        tagName: 'li'
#        template: _.template( $("#variety-item").html() )
#        events:
#            'click span.destroy': 'clear'
#
#        initialize: ->
#            @model.bind('destory', @remove, this)
#
#        remove: ->
#            $(@el).remove()
#
#        clear: ->
#            @model.destroy()



    $(document).ready ->
      window.App = new Varieties()

