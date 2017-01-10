matchOutsideIndia = (term, text) ->
  return true if text.toUpperCase().indexOf(term.toUpperCase()) == 0 || text.toUpperCase().indexOf('INDIA') >= 0
  false

setupStateSelect2 = ->
  $.fn.select2.amd.require ['select2/compat/matcher'], (oldMatcher) ->
    $('#mooc_student_signup_state').select2
      matcher: oldMatcher(matchOutsideIndia)

setupCollegeSelect2 = ->
  collegeInput = $('#mooc_student_signup_college_id')

  if collegeInput.length
    collegeSearchUrl = collegeInput.data('searchUrl')

    collegeInput.select2
      minimumInputLength: 3,
      placeholder: 'Please pick your college',
      ajax:
        url: collegeSearchUrl,
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

setupTogglingCollegeField = ->
  if $('#mooc_student_signup_college_id').length
    toggleCollegeTextField()
    $('#mooc_student_signup_college_id').change toggleCollegeTextField

toggleCollegeTextField = ->
  if $('#mooc_student_signup_college_id').val() == 'other'
    collegeTextInput = $("#mooc_student_signup_college_text")
    collegeTextInput.prop('disabled', false)
    collegeTextInput.parent().parent().parent().removeClass('hidden-xs-up')
    $("#mooc_student_signup_college_id").parent().parent().addClass('hidden-xs-up')
    collegeTextInput.focus()

$(document).on 'page:change', setupTogglingCollegeField

$(document).on 'turbolinks:load', ->
  if $('#six-ways__student-details').length
    setupStateSelect2()
    setupCollegeSelect2()
