#= require_tree ./incubation

toggleRollNumber = ->
  if $("#startup_admin_attributes_university_id").val()
      $('.startup_admin_roll_number').show()
    else
      $('.startup_admin_roll_number').hide()

$ ->
  toggleRollNumber()
  $("#startup_admin_attributes_university_id").change toggleRollNumber

$ ->
  $('#startup_category_ids').select2(
    placeholder : 'Select Category',
    maximumSelectionSize: 3
  )
