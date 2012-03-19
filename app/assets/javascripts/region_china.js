$(function(){

  window.Local = Backbone.Model.extend({

  });

  window.Province = Backbone.Model.extend({

  });

  window.City = Backbone.Model.extend({

  });

  window.District = Backbone.Model.extend({

  });


  window.Locals = Backbone.Collection.extend({
    model: Local,
    url: ' ',
    initialize: function(url){
      this.url = url; 
    }
  });


  window.Provinces = Backbone.Collection.extend({
    model: Province,
    url: '/api/regions/china_provinces', 

    initialize: function(parent_id){
      this.url += "?parent_id=" + parent_id;
    }
  });

  window.Cities = Backbone.Collection.extend({
    model: City,
    url: '/api/regions/china_cities',

    initialize: function(parent_id){
      this.url += "?parent_id=" + parent_id;
    } 

  });

  window.Districts = Backbone.Collection.extend({
    model: District,
    url: '/api/regions/china_districts',

    initialize: function(parent_id){
      this.url += "?parent_id=" + parent_id;
    }
  });

  $(document).ready(function() {

    window.LocationView = Backbone.View.extend({

      tagName: "option",

      initialize: function(){
        _.bindAll(this, 'render');
      },

      render: function(){
        (this.$el).attr('value', this.model.get('id')).html(this.model.get("region_name"));
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
      },
      populateFrom: function(url) {
        this.collection.url = url;
        this.collection.fetch();
        this.setDisabled(false);
      },
      setDisabled: function(disabled) {
        $(this.el).attr('disabled', disabled);
      }
    });

    window.ProvinceView = LocationsView.extend({
      setSelectedId: function(parent_id) {
        this.cityView.selectedId = null;
        this.cityView.setProvinceId(parent_id);
        this.districtView.collection.reset();
        this.districtView.setDisabled(true);
        // $("#user_users_profile_province").val(parent_id);
      }

    });

    window.CityView = LocationsView.extend({
      setSelectedId: function(parent_id) {
        this.districtView.selectedId = null;
        this.districtView.setCityId(parent_id);
        // $("#user_users_profile_city").val(parent_id);
      },
      setProvinceId: function(parent_id) {
        this.populateFrom("/api/regions/locals?parent_id=" + parent_id );
      }

    });

    window.DistrictView = LocationsView.extend({
      setSelectedId: function(parent_id) {
        // $("#user_users_profile_district").val(parent_id);
        
        // Do nothing
      },
      setCityId: function(parent_id) {
        // this.populateFrom("cities/" + cityId + "/suburbs");
        this.populateFrom("/api/regions/locals?parent_id=" + parent_id );
      }
    });

    var provinceView = new ProvinceView({ el: $("#province select"), collection: new Provinces()}); 
    var cityView = new CityView({el: $("#city select"), collection: new Cities()});
    var districtView = new DistrictView({el: $("#district select"), collection: new Districts()});

    provinceView.cityView = cityView;
    provinceView.districtView = districtView;  
    cityView.districtView = districtView;  
    
    //  设置
    $("#edit_region").click(function(){
      $("#region").toggle();
      $(this).parent().toggle();
    });
    
    $("#cancle_edit_region").click(function(){
      $("#region_province").val("");
      $("#region_city").val("");
      $("#region_district").val("");
      // 
      // console.log($("#user_users_profile_province").val());
      // console.log($("#user_users_profile_city").val());
      // console.log($("#user_users_profile_district").val());

      $("#region_text").toggle();
      $(this).parent().toggle();
    });
    
    
    
  }); // End Read


});




