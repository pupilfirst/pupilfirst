$(document).on 'page:change', ->
    $('#startup_founder_ids').select2({ placeholder : 'Add Founder' })
    $('#startup_startup_category_ids').select2({ placeholder : 'Select Category' })

showTargetsOptionally = ->
  $('.admin-startup-targets-show-button').click (event) ->
    showButton = $(event.target)
    startupId = showButton.data('startupId')
    $("#admin-startup-#{startupId}-targets-list").removeClass('hide')
    showButton.addClass('hide')

$(document).on 'page:change', showTargetsOptionally
