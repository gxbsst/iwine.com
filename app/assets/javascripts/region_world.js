$(function(){

  // MODELS
  window.Tree = Backbone.Model.extend({

  });

  // COLLECTIONS
  window.TreeOnes = Backbone.Collection.extend({
    model: Tree,
    url: '/api/regions/region_world', 

    initialize: function(parent_id){
      this.url += "?parent_id=" + parent_id;
    }
  });
  
  window.TreeTwos = Backbone.Collection.extend({
    model: Tree,
  });
  
  window.TreeThrees = Backbone.Collection.extend({
    model: Tree,
  });
  
  window.TreeFours = Backbone.Collection.extend({
    model: Tree,
  });
  
  window.TreeFives = Backbone.Collection.extend({
    model: Tree,
  });
  
  window.TreeSixs = Backbone.Collection.extend({
    model: Tree,
  });
  
  $(document).ready(function() {

    // VIEWS
    window.LocationView = Backbone.View.extend({
      tagName: "option",
      initialize: function(){
        _.bindAll(this, 'render');
      },
      render: function(){
        (this.$el).attr('value', this.model.get('id')).html(this.model.get("name_en") + "/" + this.model.get("name_zh"));
        return this;
      }
    });

    window.LocationsView = Backbone.View.extend({
      events: {
        "change": "changeSelected"
      },
      initialize: function(){
        _.bindAll(this, 'addOne', 'addAll');
        this.collection.bind('reset', this.addAll);            
      },       
      addOne: function(location){
        var locationView = new LocationView({ model: location });
        this.locationViews.push(locationView);
        $(this.el).append(locationView.render().el);
      },        
      addAll: function(){
        _.each(this.locationViews, function(locationView) { locationView.remove(); });
        this.locationViews = [];
        _.each(this.locations, function(location){ location.remove(); })
        this.collection.each(this.addOne);
        if (this.selectedId) {
          $(this.el).val(this.selectedId);
        }
      },
      changeSelected: function(){
        this.setSelectedId($(this.el).val());
        
        // 如果没有任何结果, 隐藏心啊嗯
        console.log($(this.el).val() == "");
        if ($(this.el).val() == "")
        {
          $("span.tree").hide();
        }
      },
      populateFrom: function(url) {
        self = this;
        regions = this.collection;
        regions.url = url;
        regions.fetch({
          // 如果不为空则显示select
          success: function(){
            if (regions.models.length > 0)
            {
              
               $(self.el).parent().show();
               self.setDisabled(false);       
            }
          }
        });
        // console.log(this.collection.models);
      },
      setDisabled: function(disabled) {

        $(this.el).attr('disabled', disabled);
        
      }
    });

    // ONE VIEW CLASS
    window.TreeOneView = LocationsView.extend({
      setSelectedId: function(parent_id) {
        
        this.treeTwoView.selectedId = null;
        this.treeTwoView.setTreeParentId(parent_id);
        
        this.treeThreeView.collection.reset();
        this.treeThreeView.setDisabled(true);

        this.treeFourView.collection.reset();
        this.treeFourView.setDisabled(true);

        this.treeFiveView.collection.reset();
        this.treeFiveView.setDisabled(true);

        this.treeSixView.collection.reset();
        this.treeSixView.setDisabled(true);
        
        // $("#user_users_profile_province").val(parent_id);
      }

    });

    // TWO VIEW CLASS
    window.TreeTwoView = LocationsView.extend({
      setSelectedId: function(parent_id) {
        this.treeThreeView.selectedId = null;
        this.treeThreeView.setTreeParentId(parent_id);

        this.treeFourView.collection.reset();
        this.treeFourView.setDisabled(true);

        this.treeFiveView.collection.reset();
        this.treeFiveView.setDisabled(true);

        this.treeSixView.collection.reset();
        this.treeSixView.setDisabled(true);


        // $("#user_users_profile_city").val(parent_id);
      },
      setTreeParentId: function(parent_id) {
        this.populateFrom("/api/regions/region_world?parent_id=" + parent_id );
        // console.log(this.collection.isEmpty());
      }

    });

    // THREE VIEW CLASS
    window.TreeThreeView = LocationsView.extend({
      setSelectedId: function(parent_id) {
        this.treeFourView.selectedId = null;
        this.treeFourView.setTreeParentId(parent_id);

        this.treeFiveView.collection.reset();
        this.treeFiveView.setDisabled(true);

        this.treeSixView.collection.reset();
        this.treeSixView.setDisabled(true);

      },
      setTreeParentId: function(parent_id) {
        // this.populateFrom("cities/" + cityId + "/suburbs");
        this.populateFrom("/api/regions/region_world?parent_id=" + parent_id );
      }
    });


    // FOUR VIEW CLASS
    window.TreeFourView = LocationsView.extend({
      setSelectedId: function(parent_id) {
        this.treeFiveView.selectedId = null;
        this.treeFiveView.setTreeParentId(parent_id);

        this.treeSixView.collection.reset();
        this.treeSixView.setDisabled(true);

      },
      setTreeParentId: function(parent_id) {
        // this.populateFrom("cities/" + cityId + "/suburbs");
        this.populateFrom("/api/regions/region_world?parent_id=" + parent_id );
      }
    });


    // FIVE VIEW CLASS
    window.TreeFiveView = LocationsView.extend({
      setSelectedId: function(parent_id) {
        this.treeSixView.selectedId = null;
        this.treeSixView.setTreeParentId(parent_id);

      },
      setTreeParentId: function(parent_id) {
        // this.populateFrom("cities/" + cityId + "/suburbs");
        this.populateFrom("/api/regions/region_world?parent_id=" + parent_id );
      }
    });


    // SIX VIEW CLASS
    window.TreeSixView = LocationsView.extend({
      setSelectedId: function(parent_id) {
        // Do Nothing
      },
      setTreeParentId: function(parent_id) {
        // this.populateFrom("cities/" + cityId + "/suburbs");
        // this.populateFrom("/api/regions/region_world?parent_id=" + parent_id );
      }
    });

    var treeOneView = new TreeOneView({ el: $("#tree_one select"), collection: new TreeOnes()}); 
    var treeTwoView = new TreeTwoView({el: $("#tree_two select"), collection: new TreeTwos()});
    var treeThreeView = new TreeThreeView({el: $("#tree_three select"), collection: new TreeThrees()});
    var treeFourView = new TreeFourView({el: $("#tree_four select"), collection: new TreeFours()});
    var treeFiveView = new TreeFiveView({el: $("#tree_five select"), collection: new TreeFives()});
    var treeSixView = new TreeSixView({el: $("#tree_six select"), collection: new TreeSixs()});
    
    // ONE VIEW
    treeOneView.treeTwoView = treeTwoView;
    treeOneView.treeThreeView = treeThreeView; 
    treeOneView.treeFourView = treeFourView; 
    treeOneView.treeFiveView = treeFiveView;
    treeOneView.treeSixView = treeSixView; 
     
    // TWO VIEW
    treeTwoView.treeThreeView = treeThreeView; 
    treeTwoView.treeFourView = treeFourView; 
    treeTwoView.treeFiveView = treeFiveView;
    treeTwoView.treeSixView = treeSixView; 
    
    // THREE VIEW
    treeThreeView.treeFourView = treeFourView; 
    treeThreeView.treeFiveView = treeFiveView;
    treeThreeView.treeSixView = treeSixView; 
    
    // FOUR VIEW
    treeFourView.treeFiveView = treeFiveView;
    treeFourView.treeSixView = treeSixView; 
    
    // FOUR VIEW
    treeFiveView.treeSixView = treeSixView;   
    
    
    $("#wines_register_name_zh").ajaxChosen({
        method: 'GET',
        url: '/api/wines/name_zh',
        dataType: 'json'
    }, function (data) {
        var terms = {};

        $.each(data, function (i, val) {
            // console.log(val["title"]);
            terms[i] = val["title"];
        });

        return terms;
    });
      
    
  }); // End Ready




});






