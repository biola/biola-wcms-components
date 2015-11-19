
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

  $('.change_history ul.changes').each ->
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

  # In addition each bullet point that has more than 100 chars is initially shortened
  #  and can be expanded.
  showChar = 100
  ellipsestext = '...'
  moretext = 'more'
  lesstext = 'less'
  $('.more').each ->
    content = $(this).html()
    if content.length > showChar
      c = content.substr(0, showChar)
      h = content.substr(showChar - 1, content.length - showChar)
      html = c + '<span class="moreellipses">' + ellipsestext + '&nbsp;</span><span class="morecontent"><span>' + h + '</span>&nbsp;&nbsp;<a href="" class="morelink">' + moretext + '</a></span>'
      $(this).html html

  $('.morelink').click ->
    if $(this).hasClass('less')
      $(this).removeClass 'less'
      $(this).html moretext
    else
      $(this).addClass 'less'
      $(this).html lesstext
    $(this).parent().prev().toggle()
    $(this).prev().toggle()
    false
