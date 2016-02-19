$(document).on 'page:change', ->
  $('#founder_roles').select2(
    placeholder: 'Select roles at startup'
  )

toggleUniversityFields = ->
  fieldsToToggle = [$('.founder_roll_number'),$('.founder_college_identification'), $('.founder_course'),  $('.founder_semester'), $('.founder_year_of_graduation')]
  if $("#founder_university_id").val()
    for field in fieldsToToggle
      field.show()
  else
    for field in fieldsToToggle
      field.hide()

$(document).on 'page:change', ->
  toggleUniversityFields()
  $("#founder_university_id").change toggleUniversityFields
