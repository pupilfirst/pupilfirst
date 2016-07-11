setupSelect2ForBatchApplicationTagList = ->
  batchApplicationTagList = $('#batch_application_tag_list')

  if batchApplicationTagList.length
    currentFounderTags = batchApplicationTagList.data('tags')
    select2Data = $.map currentFounderTags, (tag) ->
      {
        id: tag,
        text: tag
      }

    batchApplicationTagList.select2(
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

$(document).on 'page:change', setupSelect2ForBatchApplicationTagList
