activateBackToTopLinks = ->
  if $('.tour-banner').length
    $('.back-to-top').click (e) ->
      e.preventDefault()
      $('html, body').animate
        scrollTop: 0, 500

stickyApplyButtonOnTourPage = ->
  if $('.tour-banner').length
    stickyToggle = new Waypoint
      element: $('.tour-banner')[0],
      handler: (direction) ->
        applicationButton = $('#tour-sticky-application-button')
        if direction == 'down'
          applicationButton.removeClass('hidden-xs-up')
        else
          applicationButton.addClass('hidden-xs-up')

    bottomStickyToggle = new Waypoint.Inview
      element: $('.ready-to-apply')[0]
      enter: (direction) ->
        if direction == 'down'
          $('#tour-sticky-application-button').addClass('hidden-xs-up')
      exited: (direction) ->
        if direction == 'up'
          $('#tour-sticky-application-button').removeClass('hidden-xs-up')

removeWaypoints = ->
  if $('.tour-banner').length
    Waypoint.destroyAll()

$(document).on 'page:change', stickyApplyButtonOnTourPage
$(document).on 'page:change', activateBackToTopLinks
$(document).on 'page:before-change', removeWaypoints
