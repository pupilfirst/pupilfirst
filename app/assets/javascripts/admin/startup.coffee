setupSelect2ForStartupTagList = ->
  startupTagList = $('#startup_tag_list')

  if startupTagList.length
    startupTagList.select2
      width: '80%',
      placeholder: 'Select some tags',
      tags: true

$(document).on 'page:change', ->
    $('#startup_founder_ids').select2({ placeholder : 'Add Founder' })

showTargetsOptionally = ->
  $('.admin-startup-targets-show-link').click (event) ->
    showLink = $(event.target)
    startupId = showLink.data('startupId')
    $(".admin-startup-#{startupId}-hidden-target").removeClass('hide')
    showLink.hide()

$(document).on 'page:change', showTargetsOptionally
$(document).on 'page:change', setupSelect2ForStartupTagList
