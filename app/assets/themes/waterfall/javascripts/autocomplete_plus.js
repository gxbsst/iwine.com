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
      events: {
        "click .region ul li a" : "selectRegion"
      },

      initialize: function() {
        _.bindAll(this, 'render');
        //this.collection.bind('reset', this.render);
        this.initializeTemplate();
      },

      initializeTemplate: function() {
        this.template = _.template($(this.template).html());
      },

      render: function() {
        $(this.el).html(this.template(this.model.toJSON()));
        return this;
      },
      selectRegion: function(event){
        console.log($(event.target).attr('data-value'));
      }
  });
  

  var InputView = Backbone.View.extend({

      el: $('#query_outer'),

      events: {
        "keyup #query" : "showRegionTree"
      },

      showRegionTree: function(event){
        self = this;
        str = $(this.el).find('input').val();
        if(str.length > 2) {
          var collections = new RegionTrees();
          collections.url += "?query=" + str 
          collections.fetch({success:function(){
             self.renderRegions(collections);
          }})
        }
      },
      renderRegions: function(collections){
        //debugger;
        $("#region_tree").html("");
        collections.each(function(model){
          var regionTreeView = new RegionTreeView({model: model});
          $("#region_tree").append(regionTreeView.render().el);
        });
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
