setupSelect2 = ->
  $('#target_prerequisite_target_ids').select2({ placeholder : 'Select prerequisite targets' })

$(document).on 'turbolinks:load', ->
  if $('form.formtastic.target').length
    setupSelect2()
