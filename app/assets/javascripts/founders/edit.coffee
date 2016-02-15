$(document).on 'page:change', ->
  $('#user_roles').select2(
    placeholder: 'Select roles at startup'
  )

toggleUniversityFields = ->
  if $("#user_university_id").val()
    $('.user_roll_number').show()
    $('.user_college_identification').show()
  else
    $('.user_roll_number').hide()
    $('.user_college_identification').hide()

$(document).on 'page:change', ->
  toggleUniversityFields()
  $("#user_university_id").change toggleUniversityFields
