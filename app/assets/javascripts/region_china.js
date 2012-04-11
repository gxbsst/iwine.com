$(function(){

    window.Province = Backbone.Model.extend({
      
    });

    window.VarietyCollection = Backbone.Collection.extend({
        model: Variety,
        localStorage: new Store("varieties")
    });
    
    
  });