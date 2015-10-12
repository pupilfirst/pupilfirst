toggleRollNumber = ->
  adminUniversityId = $("#startup_admin_attributes_university_id")

  if adminUniversityId
    if adminUniversityId.val()
      $('.startup_admin_roll_number').show()
    else
      $('.startup_admin_roll_number').hide()

$(document).on 'page:change', ->
  toggleRollNumber()
  $("#startup_admin_attributes_university_id").change toggleRollNumber
