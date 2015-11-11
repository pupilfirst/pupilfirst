toggleUniversityFields = ->
  adminUniversityId = $("#startup_admin_attributes_university_id")

  if adminUniversityId
    if adminUniversityId.val()
      $('.startup_admin_roll_number').show()
      $('.startup_admin_college_identification').show()
    else
      $('.startup_admin_roll_number').hide()
      $('.startup_admin_college_identification').hide()

$(document).on 'page:change', ->
  toggleUniversityFields()
  $("#startup_admin_attributes_university_id").change toggleUniversityFields
