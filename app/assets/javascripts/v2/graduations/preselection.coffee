addressesEqualHandler = ->
  addressToggle = $('#admissions_preselection_stage_applicant_permanent_address_is_communication_address')

  # Hide the current address textarea if page loads with the option set.
  if addressToggle.prop('checked')
    $('#admissions_preselection_stage_applicant_communication_address').closest('.form-group').hide()

  addressToggle.change (event) ->
    $('#admissions_preselection_stage_applicant_communication_address').closest('.form-group').slideToggle()

$(document).on 'turbolinks:load', ->
  if $('#admissions_preselection_stage_applicant_name').length
    addressesEqualHandler()
