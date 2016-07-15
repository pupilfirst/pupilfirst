setupSelect2Inputs = ->
  $('#mooc_student_signup_university_id').select2()
  $('#mooc_student_signup_state').select2()

$(document).on 'page:change', setupSelect2Inputs
