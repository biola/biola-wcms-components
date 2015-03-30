# In order to use you must first set up an uploader
#  Example:
#    fileUploader.addUploader('embedded_image', "http://api.example.com/uploader");
#
# Then you can send a file to that uploader whenever you are ready.
#  Example:
#     fileUploader.sendFileToServer file, 'embedded_image', ((url) ->
#       alert 'success!'
#     ), ->
#       alert 'error :('
#


window.fileUploader ||= {
  uploaders: {}
}

fileUploader.addUploader = (key, url) ->
  fileUploader.uploaders[key] = url

fileUploader.sendFileToServer = (file, urlKey, successCallback, errorCallback) ->
  if fileUploader.uploaders[urlKey]
    form_data = new FormData()
    form_data.append('file', file)
    form_data.append('authenticity_token', $('[name=csrf-token]').attr('content'))

    xhr = new XMLHttpRequest()
    xhr.open "POST", fileUploader.uploaders[urlKey]

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
            alert('There was a problem uploading the file')
        else
          successCallback(json.filelink)
      return
    , this)
    xhr.send form_data

  else
    alert('Uploader is not configured.')

