# Some helper functions for uploading embeded images
window.embeddedImage ||= {}

embeddedImage.sendFileToServer = (file, successCallback, errorCallback) ->
  if embeddedImage.uploadUrl
    form_data = new FormData()
    form_data.append('file', file)
    form_data.append('authenticity_token', $('[name=csrf-token').attr('content'))

    xhr = new XMLHttpRequest()
    xhr.open "POST", embeddedImage.uploadUrl

    # complete
    xhr.onreadystatechange = $.proxy(->
      if xhr.readyState is 4
        data = xhr.responseText
        data = data.replace(/^\[/, "")
        data = data.replace(/\]$/, "")
        json = undefined
        try
          json = ((if typeof data is "string" then $.parseJSON(data) else data))
        catch err
          json = error: true

        if json.error
          if errorCallback
            errorCallback()
          else
            alert('There was a problem uploading the image')
        else
          successCallback(json.filelink)
      return
    , this)
    xhr.send form_data

  else
    alert('Upload URL has not been configured.')
