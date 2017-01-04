setupSelect2ForBatchApplicantTagList = ->
  batchApplicantTagList = $('#batch_applicant_tag_list')

  if batchApplicantTagList.length
    batchApplicantTagList.select2
      width: '80%',
      placeholder: 'Select some tags',
      tags: true

setupSelect2ForBatchApplicantColleges = ->
  collegeInput = $('#batch_applicant_college_id')

  if collegeInput.length
    collegeSearchUrl = collegeInput.data('searchUrl')

    collegeInput.select2
      width: '80%',
      minimumInputLength: 3,
      ajax:
        url: collegeSearchUrl,
        dataType: 'json',
        delay: 500,
        data: (params) ->
          return {
            q: params.term
          }
        ,
        processResults: (data, params) ->
          return { results: data }
        cache: true

$(document).on 'page:change', ->
  $('#batch_applicant_batch_application_ids').select2(
    width: '80%',
    placeholder : 'Select applications'
  )

toggleCollegeFormFieldsIfRequired = ->
  checkbox = $('#aa_batch_applicant_enable_create_college_checkbox')

  if checkbox.length
    collegeFormInputs = $("[name*='batch_applicant[college_attributes]']")

    if checkbox.prop('checked')
      collegeFormInputs.prop('disabled', false)
    else
      collegeFormInputs.prop('disabled', true)

enableCreateCollegeFormOnRequest = ->
  $('#aa_batch_applicant_enable_create_college_checkbox').click toggleCollegeFormFieldsIfRequired

$(document).on 'page:change', toggleCollegeFormFieldsIfRequired
$(document).on 'page:change', enableCreateCollegeFormOnRequest
$(document).on 'page:change', setupSelect2ForBatchApplicantColleges
$(document).on 'page:change', setupSelect2ForBatchApplicantTagList
