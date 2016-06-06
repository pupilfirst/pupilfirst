$(document).on 'page:change', ->
  $('#batch_applicant_batch_application_ids').select2(
    width: '80%',
    placeholder : 'Select applications'
  )
