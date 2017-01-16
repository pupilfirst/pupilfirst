setupSelect2 = ->
  $('#target_prerequisite_target_ids').select2({ placeholder : 'Select prerequisite targets' })
  $('#target_timeline_event_type_id').select2()
  $('#target_target_group_id').select2()

$(document).on 'turbolinks:load', ->
  if $('#admin-target__edit').length
    setupSelect2()
