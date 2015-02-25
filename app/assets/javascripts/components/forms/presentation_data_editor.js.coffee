$(document).ready ->
  if $('#presentation_data_editor').length > 0

    # Disable all framework fields, otherwise they will save on submit
    $('.array_wrapper .framework').find('input, textarea').each ->
      this.disabled = true

    # Delete an array item when you click the delete button
    $('.array_wrapper').on 'click', '.delete_array_item', ->
      $(this).parents('.array_item').remove()
      false

    # Add an new array item from the last array_item
    $('.array_wrapper .add_array_item').click ->
      last_item = $(this).siblings('.array_item').last()
      framework = $(this).siblings('.array_item.framework').last()
      new_item = framework.clone()
      new_item.removeClass("framework")

      # Get array number for last item
      last_number = last_item.find('input, textarea').first().attr('id').match(/\d+/)
      new_number = +last_number[0] + 1

      # Loop through each element and enable it.
      # They have to be disabled in the framework form so they don't get submitted
      new_item.find('input, textarea').each ->
        this.id = this.id.replace(/\d+/, new_number)
        this.disabled = false
        this.value = ""

      # Append to DOM after last item
      last_item.after(new_item)

      # Setup redactor for new item
      #   NOTE: This is the reason I am copying the 'framework' item above,
      #    because redactor is already setup for the other items.
      #    I explicitly exclude redactor setup from items nested under 'framework'
      setupRedactorEditorsUnder(new_item)

      false





    ##############################
    # Setup drag-drop image upload
    ##############################
    uploadImage = (file, input) ->
      embeddedImage.sendFileToServer file, ((url) ->
        input.value = url
      ), ->
        alert('There was a problem uploading the image')

    $('#presentation_data_editor').on 'dragover', 'input.drop-image-uploader', (e) ->
      event.preventDefault()
      event.stopPropagation()
      $(this).addClass('dragging')

    $('#presentation_data_editor').on 'dragleave', 'input.drop-image-uploader', (e) ->
      event.preventDefault()
      event.stopPropagation()
      $(this).removeClass('dragging')

    $('#presentation_data_editor').on 'drop', 'input.drop-image-uploader', (e) ->
      event.preventDefault()
      event.stopPropagation()
      uploadImage(e.originalEvent.dataTransfer.files[0], this)
      $(this).removeClass('dragging')
