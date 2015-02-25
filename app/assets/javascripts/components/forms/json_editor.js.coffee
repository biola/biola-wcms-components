$(document).ready ->
  $('.ace_json_editor').each ->
    editor_area = document.createElement('div')
    this.appendChild(editor_area)

    # Initialize Ace Editor
    editor = ace.edit(editor_area)
    editor.getSession().setMode("ace/mode/json")
    editor.getSession().setTabSize(2)
    editor.getSession().setUseWrapMode(true);
    editor.setPrintMarginColumn(800)
    editor.setOptions({
      minLines: 8,
      maxLines: Infinity
    });

    textarea = $(this).children('textarea').hide()
    editor.getSession().setValue textarea.val()
    editor.getSession().on "change", ->
      textarea.val editor.getSession().getValue()
