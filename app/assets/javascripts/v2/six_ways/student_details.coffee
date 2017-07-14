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

setupPasswordHintButtons = ->
  $('#mooc-student-form__password-hint-accept').on('click', replaceEmailWithHint)
  $('#mooc-student-form__password-hint-reject').on('click', acceptEmailInputfromUser)

replaceEmailWithHint = (event) ->
  $('#mooc_student_signup_email').val($('#mooc_student_signup_email').data('replacementHint'))
  event.preventDefault()
  $(event.target).closest('.help-block').slideUp()

acceptEmailInputfromUser = (event) ->
  $('#mooc_student_signup_ignore_email_hint').val('true')
  event.preventDefault()
  $(event.target).closest('.help-block').slideUp()

$(document).on 'page:change', setupTogglingCollegeField

$(document).on 'turbolinks:load', ->
  if $('#six-ways__student-details').length
    setupCollegeSelect2()
    setupPasswordHintButtons()
