toggleReferenceTextField = ->
  if $('#batch_applicant_reference').val() == 'Other (Please Specify)'
    $('#batch_applicant_reference_text').show()
  else
    $('#batch_applicant_reference_text').val('')
    $('#batch_applicant_reference_text').hide()

$(document).on 'page:change', ->
  toggleReferenceTextField()
  $('#batch_applicant_reference').change toggleReferenceTextField
