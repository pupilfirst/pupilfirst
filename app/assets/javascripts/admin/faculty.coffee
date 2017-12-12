setupSelect2ForFounder = ->
  founderInput = $('#faculty_founder_id')

  if founderInput.length > 0
    founderInput.select2
      allowClear: true,
      width: '80%',
      placeholder: 'Search by Name',
      minimumInputLength: 3,
      ajax:
        url: '/admin/founders/search_founder',
        dataType: 'json',
        delay: 500,
        data: (params) ->
          return {
            q: params.term
          }
        ,
        processResults: (data, params) ->
          return { results: data }
        cache: true

$(document).on 'turbolinks:load', ->
  if $('#admin-faculty__form').length
    setupSelect2ForFounder()
