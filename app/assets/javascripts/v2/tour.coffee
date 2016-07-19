$(document).on 'page:change', ->
  $(".dropdown-menu").find("a").click (e) ->
    e.preventDefault()
    section = $(this).attr "href"
    $("html, body").animate
      scrollTop: $(section).offset().top

  $('.back-to-top').click (e) ->
    e.preventDefault()
    $('html, body').animate
      scrollTop: 0, 500

stickyApplyButtonOnTourPage = ->

  if $('.sticky-application-button')
    stickyToggle = new Waypoint
      element: $('.tour-banner')[0],
      handler: (direction) ->
        applicationButton = $('.sticky-application-button')
        if direction == 'down'
          applicationButton.removeClass('hidden-xs-up')
        else
          applicationButton.addClass('hidden-xs-up')

    bottomStickyToggle = new Waypoint.Inview
      element: $('footer')[0]
      enter: (direction) ->
        if direction == 'down'
          $('.sticky-application-button').addClass('stick-above-footer')
      exited: (direction) ->
        if direction == 'up'
          $('.sticky-application-button').removeClass('stick-above-footer')

$(document).on 'page:change', stickyApplyButtonOnTourPage
