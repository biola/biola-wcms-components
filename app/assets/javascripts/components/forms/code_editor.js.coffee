$(document).ready ->
  $('.ace_code_editor').each ->
    editor_area = document.createElement('div')
    this.appendChild(editor_area)
    mode = "ace/mode/" + this.dataset.mode

    # Initialize Ace Editor
    editor = ace.edit(editor_area)
    editor.getSession().setMode(mode)
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
