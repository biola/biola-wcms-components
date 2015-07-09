setupRedactor = (obj) ->
  # Default Options
  options =
    minHeight: 200
    allowedTags: ['p', 'br', 'span']
    buttons: []
    plugins: []
    toolbarFixed: false

  if fileUploader.uploaders && fileUploader.uploaders.embedded_image
    options.imageUpload = fileUploader.uploaders.embedded_image
    options.allowedTags = $.merge(options.allowedTags, ['img'])

  # Add any custom data attributes to the default options
  if obj.data('linkable')  # in case you want to support links without explicitly giving a link button.
    options.allowedTags = $.merge(options.allowedTags, ['a'])
  if obj.data('allow-divs')
    options.allowedTags = $.merge(options.allowedTags, ['div'])
    options.replaceDivs = false
  if data = obj.data('buttons')
    buttons = data.split(' ')
    options.buttons = $.merge(options.buttons, buttons)
    options.allowedTags = $.merge(options.allowedTags, buttonsToTags(buttons))
  if tuned_data = obj.data('formatting')
    formatting = tuned_data.split (' ')
    options.formatting = tuned_data.split (' ')
  if options.allowedTags.indexOf('a') >= 0
    options.convertLinks = true;
  if options.buttons.indexOf('fullscreen') >= 0
    options.plugins.push 'fullscreen'
  if options.buttons.indexOf('table') >= 0
    options.plugins.push 'table'
  if options.buttons.indexOf('video') >= 0
    options.plugins.push 'video'

  # Uniq all arrays
  options.buttons = $.unique(options.buttons)
  if formatting
    options.formatting = $.unique(options.formatting)
    options.allowedTags = options.allowedTags.concat(options.formatting)
  options.allowedTags = $.unique(options.allowedTags)

  # Initialize redactor
  obj.redactor(options)


button_to_tag_mapping =
  bold: ['b', 'strong']
  italic: ['i', 'em']
  link: ['a']
  orderedlist: ['ol', 'li']
  table: ['table', 'tr', 'tbody', 'td']
  unorderedlist: ['ul', 'li']
  video: ['iframe']

buttonsToTags = (buttons) ->
  tags = []
  $.each buttons, (index, value) ->
    if mapping = button_to_tag_mapping[value]
      tags = $.merge(tags, mapping)
  tags


window.setupRedactorEditorsUnder = (obj) ->
  # Initialize redactor on items with the class 'redactor'
  $(obj).find("textarea.redactor:enabled").each (i) ->
    # Don't setup redactor if the textarea inherits from a "framework" item.
    #   framework items are hidden and are used to add new items to a form array.
    # If it inherits from .redactor-box that means it has already been initialized.
    unless $(this).parents('.framework, .redactor-box').length > 0
      setupRedactor($(this))


$(document).ready ->
  # Run on startup
  setupRedactorEditorsUnder('body')

  # Run when modals open
  $(".modal").on "shown.bs.modal", (e) ->
    setupRedactorEditorsUnder('.modal')
