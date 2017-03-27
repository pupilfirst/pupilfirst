setupSelect2 = ->
  $('#target_prerequisite_target_ids').select2({placeholder: 'Select prerequisite targets'})
  $('#target_timeline_event_type_id').select2()
  $('#target_target_group_id').select2()

  $('#target_tag_list').select2(
    width: '80%',
    placeholder: 'Select some tags',
    tags: true
  )

destroySelect2 = ->
  $('#target_tag_list').select2('destroy')
  $('#target_target_group_id').select2('destroy')
  $('#target_timeline_event_type_id').select2('destroy')
  $('#target_prerequisite_target_ids').select2('destroy')

$(document).on 'turbolinks:load', ->
  if $('#admin-target__edit').length > 0
    setupSelect2()

$(document).on 'turbolinks:before-cache', ->
  if $('#admin-target__edit').length > 0
    destroySelect2()
