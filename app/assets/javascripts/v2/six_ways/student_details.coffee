setupSelect2Inputs = ->
  universityInput = $('#mooc_student_signup_university_id')

  if universityInput.length
    universitySearchUrl = universityInput.data('searchUrl')

    universityInput.select2
      minimumInputLength: 3,
      placeholder: 'Please pick your university',
      ajax:
        url: universitySearchUrl,
        dataType: 'json',
        delay: 500,
        data: (params) ->
          return {
            q: params.term
          }
        ,
        processResults: (data, params) ->
          return { results: data }
        ,
        cache: true

    $('#mooc_student_signup_state').select2
      matcher: (term, text, opt) ->
        text.toUpperCase().indexOf(term.toUpperCase()) >= 0 || opt.html().toUpperCase().indexOf('INDIA') >= 0

$(document).on 'page:change', setupSelect2Inputs
