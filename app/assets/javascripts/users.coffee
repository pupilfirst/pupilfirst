toggleUserRollNumber = ->
  if $("#user_university_id").val()
      $('.user_roll_number').show()
    else
      $('.user_roll_number').hide()

$ ->
  toggleUserRollNumber()
  $("#user_university_id").change toggleUserRollNumber
