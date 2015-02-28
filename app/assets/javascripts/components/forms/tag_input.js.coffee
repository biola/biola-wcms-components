initializeTaginput = (selector) ->
  $(selector).each ->
    tagsinput = $(this)
    tagsinputOptions = {}


    # If typeahead key is set, initialize typeahead. Otherwise just initialize a normal tagsinput
    #   available parameters:
    #     :url  => url to the remote json data
    #     :key  => the key to use for each element in the json array
    #     :query_param  => The parameter key we should use to append the search to the url
    #                      Defaults to 'q'
    #
    if options = tagsinput.data('typeahead')
      options.query_param ||= 'q'

      typeaheadEngine = new Bloodhound
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace(options.key)
        queryTokenizer: Bloodhound.tokenizers.whitespace
        remote: "#{options.url}?#{options.query_param}=%QUERY"
      typeaheadEngine.initialize()

      tagsinputOptions.typeaheadjs =
        displayKey: options.key
        valueKey: options.key
        highlight: true
        source: typeaheadEngine.ttAdapter()

    # Initialize tagsinput with options
    tagsinput.tagsinput tagsinputOptions



$(document).ready ->

  # Initialize tagsinput on page load
  initializeTaginput("input[data-role=tagsinput]")

  $(".modal").on "shown.bs.modal", (e) ->
    # Initialize tagsinputs underneath modal.
    initializeTaginput("input[data-role=tagsinput]")

