$(document).ready ->
  if $('.person-lookup').length > 0
    people_search_url = $('.person-lookup').first().data('lookup-url')

    peopleSearch = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('id')
      queryTokenizer: Bloodhound.tokenizers.whitespace
      # The prefetch url returns a list of all the faculty
      prefetch: people_search_url
      remote: people_search_url + '?q=%QUERY'
    )

    peopleSearch.initialize()
    $('.person-lookup .typeahead').typeahead null,
      name: 'people-search'
      displayKey: (person) ->
        person.name + " <#{person.email || person.id}>"
      highlight: true
      source: peopleSearch.ttAdapter()
      templates:
        empty: '<div class="tt-empty-message">No one found with that name</div>'
        suggestion: Handlebars.compile(
          '<span class="image" style="background-image: url({{image}})" ></span>' +
          '<span class="name">{{name}}</span> <span class="affiliations">{{affiliations}}</span>'
        )

    # We need to submit the ID through a hidden input for improved lookup.
    $('.person-lookup .typeahead').on "typeahead:selected typeahead:autocompleted", (e,datum) ->
      $('.person-lookup .hidden-person-id').val datum.id
