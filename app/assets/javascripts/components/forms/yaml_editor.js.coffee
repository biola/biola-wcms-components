# This is depricated. We will keep this around until we have moved everything over to the new
#  plain data form editor.

$(document).ready ->
  $('.ace_yaml_editor').each ->
    editor_area = document.createElement('div')
    this.appendChild(editor_area)

    # Initialize Ace Editor
    editor = ace.edit(editor_area)
    editor.getSession().setMode("ace/mode/yaml")
    editor.getSession().setTabSize(2)
    editor.setPrintMarginColumn(800)
    editor.setOptions({
      minLines: 8,
      maxLines: Infinity
    });

    textarea = $(this).children('textarea').hide()
    editor.getSession().setValue textarea.val()
    editor.getSession().on "change", ->
      textarea.val editor.getSession().getValue()


    # Setup drag-drop image upload
    editor.container.addEventListener 'dragover', (e) =>
      e.preventDefault()
      e.stopPropagation()

    editor.container.addEventListener 'dragleave', (e) =>
      e.preventDefault()
      e.stopPropagation()

    editor.container.addEventListener 'drop', (e) =>
      e.preventDefault()
      e.stopPropagation()
      fileUploader.sendFileToServer e.dataTransfer.files[0], 'embedded_image', (url) ->
        editor.insert('"' + url + '"')
