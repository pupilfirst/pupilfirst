toggleRollNumber = ->
  if $("#startup_admin_attributes_university_id").val()
    $('.startup_admin_roll_number').show()
  else
    $('.startup_admin_roll_number').hide()

$(document).on('ready page:load', ->
  toggleRollNumber()
  $("#startup_admin_attributes_university_id").change toggleRollNumber
)
