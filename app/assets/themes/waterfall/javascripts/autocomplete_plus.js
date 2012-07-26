var RegionTree = Backbone.Model.extend();

var RegionTrees = Backbone.Collection.extend({
  model: RegionTree,
    url: '/api/regions/region_tree' 
});

$(document).ready(function(){
  _.templateSettings = {
    interpolate: /\<\@\=(.+?)\@\>/g,
  evaluate: /\<\@(.+?)\@\>/g
  };

  var RegionTreeView = Backbone.View.extend({
    template: "#regiontree-template",
      className: 'album',

      initialize: function() {
        _.bindAll(this, 'render');
        this.collection.bind('reset', this.render);
        this.initializeTemplate();
      },

      initializeTemplate: function() {
        this.template = _.template($(this.template).html());
      },

      render: function() {
        $(this.el).html(this.template({collection:this.collection.toJSON()}));
        return this;
      }
  });

  var InputView = Backbone.View.extend({

      el: $('#query_outer'),

      events: {
        "keypress #query" : "showRegionTree"
      },

      showRegionTree: function(event){
        str = $(this.el).find('input').val();
        if(str.length > 3) {
          var collection = new RegionTrees();
          collection.url += "?query=" + str 
          collection.fetch({success:function(){
            var regionTreeView = new RegionTreeView({collection: collection});
            $("#region_tree").html("");
            $("#region_tree").append(regionTreeView.render().el);
          }})
        }
      },

      // 计数
      countText: function(event){
        this.showError('');
        this.showSuccess('');
        str = $(this.el).find('textarea').val();
        if(str == "")
          return;
        this.strCount = this.getStrleng(str);
      },

      getStrleng: function(str) {
        var r= new RegExp(
            '[A-Za-z0-9_\]+|'+                             // ASCII letters (no accents)
            '[\u3040-\u309F]+|'+                           // Hiragana
            '[\u30A0-\u30FF]+|'+                           // Katakana
            '[\u4E00-\u9FFF\uF900-\uFAFF\u3400-\u4DBF]',   // Single CJK ideographs
            'g');
        var nwords= str.match(r).length;
        return nwords;
      }
  });

  window.inputView = new InputView({el: $("#query_outer")});

});
