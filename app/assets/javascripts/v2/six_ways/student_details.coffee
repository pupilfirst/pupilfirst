matchOutsideIndia = (term, text) ->
  return true if text.toUpperCase().indexOf(term.toUpperCase()) == 0 || text.toUpperCase().indexOf('INDIA') >= 0
  false

setupStateSelect2 = ->
  $.fn.select2.amd.require ['select2/compat/matcher'], (oldMatcher) ->
    $('#mooc_student_signup_state').select2
      matcher: oldMatcher(matchOutsideIndia)

setupUniversitySelect2 = ->
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

$(document).on 'turbolinks:load', ->
  if $('#six-ways__student-details').length
    setupUniversitySelect2()
    setupStateSelect2()
