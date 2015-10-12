$(document).on('ready page:load', ->
  $('#user_roles').select2(
    placeholder: 'Select roles at startup'
  )
)

toggleUserRollNumber = ->
  if $("#user_university_id").val()
    $('.user_roll_number').show()
  else
    $('.user_roll_number').hide()

$(document).on('ready page:load', ->
  toggleUserRollNumber()
  $("#user_university_id").change toggleUserRollNumber
)
