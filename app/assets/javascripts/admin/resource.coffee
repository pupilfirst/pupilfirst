$(document).on 'page:change', ->
  resourceTagList = $('#resource_tag_list')

  if resourceTagList.length
    currentResourceTags = resourceTagList.data('tags')
    select2Data = $.map currentResourceTags, (tag) ->
      {
        id: tag,
        text: tag
      }

    resourceTagList.select2(
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
