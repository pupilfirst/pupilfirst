$(document).on 'page:change', ->
  $('#founder_roles').select2(
    placeholder: 'Select roles at startup'
  )

toggleUniversityFields = ->
  if $("#founder_university_id").val()
    $('.founder_roll_number').show()
    $('.founder_college_identification').show()
  else
    $('.founder_roll_number').hide()
    $('.founder_college_identification').hide()

$(document).on 'page:change', ->
  toggleUniversityFields()
  $("#founder_university_id").change toggleUniversityFields
