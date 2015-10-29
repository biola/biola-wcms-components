$(document).ready ->
  $('.change_history ul.changes').each ->
    if $(this).children('li').length > 2
      $(this).children('li').slice(2).hide()
      $(this).children('a').show()

      $(this).children('a').click (event) ->
        $(this).siblings('li').show()
        $(this).hide()
        event.preventDefault()

