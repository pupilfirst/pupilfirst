setupUniversitySelect2 = ->
  $('#user_university_id').select2()

$(document).on 'page:change', setupUniversitySelect2
