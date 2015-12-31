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
