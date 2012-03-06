# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('#wines_register_variety_name').autocomplete
    source: $('#wines_register_variety_name').data('autocomplete-source')
    minLength: 0
  .focus ->
    $(@).autocomplete("search", "is_recommend")

