$(document).ready ->
  if element = document.getElementById('presentation_data_editor')
    options = {
      theme: 'bootstrap3',
      iconlib: 'fontawesome4'
    }
    if element.dataset.schema
      options['schema'] = JSON.parse(element.dataset.schema)
    if element.dataset.startval
      options['startval'] = JSON.parse(element.dataset.startval)

    editor = new JSONEditor(element, options)

    # Watch for form changes and apply them to the hidden json value field
    # This is what will actually get submitted and processed
    pdata = $('#pdata')
    editor.on 'change', ->
      pdata.val(JSON.stringify(editor.getValue()))

    # TODO: Photos don't work the same way they used to, what I would like to do
    # is add normal photo upload support that uploads the photo as an attachment
    # to the parent object and then saves the url in the photo field.
