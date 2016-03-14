$(document).on 'page:change', ->
  $('#founder_startup_id').select2(width: '400px')

setupSelect2ForFounderTagList = ->
  founderTagList = $('#founder_tag_list')
  currentFounderTags = founderTagList.data('tags')
  select2Data = $.map currentFounderTags, (tag) ->
    {
      id: tag,
      text: tag
    }

  founderTagList.select2(
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

$(document).on 'page:change', setupSelect2ForFounderTagList
