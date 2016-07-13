setupUniversitySelect2 = ->
  $('#mooc_student_signup_university_id').select2()

$(document).on 'page:change', setupUniversitySelect2
