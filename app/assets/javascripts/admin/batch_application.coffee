setupSelect2ForBatchApplicationTagList = ->
  batchApplicationTagList = $('#batch_application_tag_list')

  if batchApplicationTagList.length
    batchApplicationTagList.select2
      width: '80%',
      placeholder: 'Select some tags',
      tags: true

$(document).on 'page:change', setupSelect2ForBatchApplicationTagList
