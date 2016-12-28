setupSelect2 = ->
  $('#target_prerequisite_target_ids').select2({ placeholder : 'Select prerequisite targets' })
  $('#target_timeline_event_type_id').select2()

$(document).on 'turbolinks:load', ->
  if $('form.formtastic.target').length
    setupSelect2()
