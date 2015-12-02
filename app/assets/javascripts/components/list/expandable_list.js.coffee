
$(document).ready ->
  # Used in Changes. For each recorded change if there is more than two changed fields
  #  hide all but the first two and provide a link to show the rest.
  onClickMoreLink = (event) ->
    link = $(event.target)
    # Show all the list items
    link.siblings('li').show()
    # Hide the show more link
    link.hide()
    # Prevent the page from scrolling to the top
    false

  $('ul.expandable_list').each ->
    ul = $(this)
    lis = ul.children('li')
    # If there are more than two list items
    if lis.length > 2
      # Show only the first two initially
      lis.slice(2).hide()

      # Create a link
      show_more_link = $('<a class="show_more_link" href="#">Expand</a>')
      # Add a click event to the link
      show_more_link.click(onClickMoreLink)
      # Add the link to the DOM
      ul.append(show_more_link)
