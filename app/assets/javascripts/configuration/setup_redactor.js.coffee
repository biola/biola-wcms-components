setupRedactor = (obj) ->
  # Default Options
  options =
    minHeight: 200
    plugins: ['table', 'video', 'fullscreen']
    toolbarFixed: false
    replaceDivs: false

  if fileUploader.uploaders && fileUploader.uploaders.embedded_image
    options.imageUpload = fileUploader.uploaders.embedded_image

  # Initialize redactor
  obj.redactor(options)

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
