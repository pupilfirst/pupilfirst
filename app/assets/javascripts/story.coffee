prepPage = ->
  $('#transparency-sidebar').stickit(top: 20)

  sections = $('section')
  navElement = $('nav')
  navElementHeight = navElement.outerHeight()

  $(window).on 'scroll', ->
    currentPosition = $(this).scrollTop()

    sections.each ->
      top = $(this).offset().top - navElementHeight
      bottom = top + $(this).outerHeight()

      if currentPosition >= top - 20 and currentPosition <= bottom
        navElement.find('a').removeClass 'active'
        sections.removeClass 'active'
        $(this).addClass 'active'
        navElement.find('a[href="#' + $(this).attr('id') + '"]').addClass 'active'

  $('#transparency-sidebar').find('a').click (event) ->
    event.preventDefault()
    $.scrollTo $(this).attr('href'), 500, offset: -95
    $('.active').removeClass 'active'
    $(this).addClass 'active'

$(document).on 'turbolinks:load', ->
  if $('.home__story').length > 0
    prepPage()
