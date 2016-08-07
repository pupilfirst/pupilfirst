setupSelect2Inputs = ->
  universityInput = $('#mooc_student_signup_university_id')

  if universityInput.length
    universitySearchUrl = universityInput.data('searchUrl')

    universityInput.select2
      minimumInputLength: 3,
      ajax:
        url: universitySearchUrl,
        dataType: 'json',
        quietMillis: 500,
        data: (term, page) ->
          return {
            q: term
          }
        ,
        results: (data, page) ->
          return { results: data }
        cache: true

    $('#mooc_student_signup_state').select2()

$(document).on 'page:change', setupSelect2Inputs
