toggleReferenceTextField = ->
  if $('#batch_applicant_signup_reference').val() == 'Other (Please Specify)'
    $('#batch_applicant_signup_reference_text').show()
  else
    $('#batch_applicant_signup_reference_text').val('')
    $('#batch_applicant_signup_reference_text').hide()

$(document).on 'page:change', ->
  if $('#batch_applicant_signup_reference').length
    toggleReferenceTextField()
    $('#batch_applicant_signup_reference').change toggleReferenceTextField
