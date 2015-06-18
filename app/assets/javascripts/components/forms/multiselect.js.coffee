$(document).ready ->
  $('.bs-multiselect').each ->
    $(this).multiselect
      enableCaseInsensitiveFiltering: true
      enableFiltering: true
      filterBehavior: 'value'
      includeSelectAllOption: false
      maxHeight: 400
      numberDisplayed: 1

  # Replace glyphicons with fonticons
  if $('.bs-multiselect').length > 0
    $('i.glyphicon.glyphicon-search').removeClass('glyphicon glyphicon-search').addClass('fa fa-search');
    $('i.glyphicon.glyphicon-remove-circle').removeClass('glyphicon glyphicon-remove-circle').addClass('fa fa-times-circle');
