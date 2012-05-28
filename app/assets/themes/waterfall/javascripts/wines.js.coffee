# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('#wines_register_variety_name_value').autocomplete
    source: $('#wines_register_variety_name_value').data('autocomplete-source')
    minLength: 0
  .focus ->
    $(@).autocomplete("search", "is_recommend")

  $('#wines_register_winery_id').autocomplete
    source: $('#wines_register_winery_id').data('autocomplete-source')

  $('#variety_name').autocomplete
    source: $('#variety_name').data('autocomplete-source')

  $("#message_recipients").autocomplete
      source: $("#message_recipients").data("autocomplete-source")



