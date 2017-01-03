$(document).on 'page:change', ->
  resourceTagList = $('#resource_tag_list')

  if resourceTagList.length
    resourceTagList.select2
      width: '80%',
      placeholder: 'Select some tags',
      tags: true
