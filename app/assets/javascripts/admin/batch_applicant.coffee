setupSelect2ForBatchApplicantTagList = ->
  batchApplicantTagList = $('#batch_applicant_tag_list')

  if batchApplicantTagList.length
    currentFounderTags = batchApplicantTagList.data('tags')
    select2Data = $.map currentFounderTags, (tag) ->
      {
        id: tag,
        text: tag
      }

    batchApplicantTagList.select2(
      width: '80%',
      placeholder: 'Select some tags',
      tags: true,
      data: select2Data,
      createSearchChoice: (term, data) ->
        filteredData = $(data).filter ->
          this.text.localeCompare(term) == 0

        if filteredData.length == 0
          return {id: term, text: term}
    )

$(document).on 'page:change', ->
  $('#batch_applicant_batch_application_ids').select2(
    width: '80%',
    placeholder : 'Select applications'
  )

$(document).on 'page:change', setupSelect2ForBatchApplicantTagList
