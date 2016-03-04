setupSelect2ForStartupTagList = ->
  startupTagList = $('#startup_tag_list')
  currentStartupTags = startupTagList.data('tags')
  select2Data = $.map currentStartupTags, (tag) ->
    {
      id: tag,
      text: tag
    }

  startupTagList.select2(
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
    $('#startup_founder_ids').select2({ placeholder : 'Add Founder' })
    $('#startup_startup_category_ids').select2({ placeholder : 'Select Category' })

showTargetsOptionally = ->
  $('.admin-startup-targets-show-link').click (event) ->
    showLink = $(event.target)
    startupId = showLink.data('startupId')
    $(".admin-startup-#{startupId}-hidden-target").removeClass('hide')
    showLink.hide()

$(document).on 'page:change', showTargetsOptionally
$(document).on 'page:change', setupSelect2ForStartupTagList
