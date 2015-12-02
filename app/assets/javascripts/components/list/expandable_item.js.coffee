$(document).ready ->
  # Each bullet point that has more than 100 chars is initially shortened
  #  and can be expanded.
  showChar = 100
  ellipsestext = '...'
  moretext = 'more'
  lesstext = 'less'

  onClickMoreLink = (event) ->
    link = $(event.target)

    if link.hasClass('less')
      link.removeClass 'less'
      link.html moretext
    else
      link.addClass 'less'
      link.html lesstext

    link.parent().prev().toggle()
    link.prev().toggle()
    # Prevent the page from scrolling to the top.
    false


  $('.expandable_item').each ->
    content = $(this).html()
    if content.length > showChar
      c = content.substr(0, showChar)
      h = content.substr(showChar)
      html = c + '<span class="moreellipses">' + ellipsestext + '&nbsp;</span><span class="morecontent"><span>' + h + '</span>&nbsp;&nbsp;<a href="" class="morelink">' + moretext + '</a></span>'
      $(this).html html

  $('.expandable_item .morelink').click onClickMoreLink
