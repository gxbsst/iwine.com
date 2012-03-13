// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//

//= require jquery
//= require jquery_ujs
//= require underscore
//= require backbone
//= require backbone-localstorage
//= require fancybox
//= require jcrop
//= require swfobject
//= require jquery.uploadify.v2.1.4


$(function(){

    window.Variety = Backbone.Model.extend({
        defaults: {
            name: '',
            percentage: ''
        },
        validate: function(attrs)
        {
            if(attrs.percentage == '')
            {
                return '葡萄百分比不能为空！';
            }
            var reg = /^-?\d+%$/;
            if( !reg.test(attrs.percentage))
            {
              return '葡萄百分比格式不正确， 格式如: 15%';
            }
        }
    });

    window.VarietyCollection = Backbone.Collection.extend({
        model: Variety,
        localStorage: new Store("varieties")
    });

    window.VarietyCollection = new VarietyCollection();

    window.Varieties = Backbone.View.extend({

//        template: _.template( $("#variety_item").html()),

        events: {
            "click span#create_variety" : "createVariety"
        },

        initialize: function() {
            this.name_input = this.$("#wines_register_variety_name");
            this.percentage_input = this.$("#new_variety");
            VarietyCollection.bind('add', this.addOne, this);
        },

        render: function() {
        },

        addOne: function(model) {
            var view = new VarietyItem({model : model});
            $("#variety_items").append(view.render().el);
            $('#wines_register_variety_name option:selected').removeAttr('selected').next('option').attr('selected', 'selected');
        },

        createVariety: function(){
            var variety = {
                name_value : this.name_input.val(),
                name : this.$("#wines_register_variety_name option:selected").text(),
                percentage : this.percentage_input.val()
            };
            VarietyCollection.create(variety, {error: this.handleError, success: this.handleSuccess});
            this.percentage_input.val('');
        },

        handleError: function(model, response){
            $('span.variety_percentage_error').text(response);
        },

        handleSuccess: function(model, response){
            $('span.variety_percentage_error').text('');
        }

    });

    window.VarietyItem = Backbone.View.extend({

        events: {
            "click span.variety_destroy"   : "clear"
        },

        tagName: 'li',

        template: _.template($('#variety_item').html()),

        initialize: function() {
            this.model.bind('destroy', this.remove, this);
        },

        render: function() {
            $(this.el).html(this.template(this.model.toJSON()));
            this.setText();
            return this;
        },

        remove: function() {
            $(this.el).remove();
        },

        clear: function() {
            this.model.destroy();
        },

        setText: function() {
            this.$('.variety_name').text(this.model.get('name'));
            this.$('.variety_name_value_hidden').val(this.model.get('name_value'));
            this.$('.variety_percentage_hidden').val(this.model.get('percentage'));
            this.$('.variety_percentage').text(this.model.get('percentage'));
        }

    });

    window.App = new Varieties({el: $("#new_wines_register")});

});


