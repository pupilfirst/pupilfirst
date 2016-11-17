addressesEqualHandler = ->
  $('#application_stage_four_permanent_address_is_current_address').change (event) ->
    $('#application_stage_four_current_address').closest('.form-group').slideToggle()

$(document).on 'turbolinks:load', ->
  if $('#update_applicant_form').length
    addressesEqualHandler()
