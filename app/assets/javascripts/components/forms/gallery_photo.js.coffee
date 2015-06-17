$(document).ready ->

  $('.gallery_photos.sortable').sortable
    items: ".gallery_photo"
    containment: "parent"
    start: (e, info) ->
      info.item.siblings(".selected").not(".ui-sortable-placeholder").appendTo info.item

    stop: (e, info) ->
      info.item.after info.item.find("li")

    update: ->
      $.ajax
        type: "PUT"
        # url: ROOT_URL + "gallery_photos/sort"
        url: (location.protocol + '//' + location.host + location.pathname).replace(/(\/$|\/edit)/, '') + "/gallery_photos/sort"
        data: $(this).sortable("serialize")
        dataType: "script"
