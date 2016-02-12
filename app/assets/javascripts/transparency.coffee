$(document).on 'page:change', ->

  $('#sidebar').stickit
    top: 100
    extraHeight: -30
  sections = $('section')
  nav = $('nav')
  nav_height = nav.outerHeight()
  $(window).on 'scroll', ->
    cur_pos = $(this).scrollTop()
    sections.each ->
      top = $(this).offset().top - nav_height
      bottom = top + $(this).outerHeight()
      if cur_pos >= top - 20 and cur_pos <= bottom
        nav.find('a').removeClass 'active'
        sections.removeClass 'active'
        $(this).addClass 'active'
        nav.find('a[href="#' + $(this).attr('id') + '"]').addClass 'active'
      return
    return
  $('#sidebar ul li a').click (e) ->
    e.preventDefault()
    $.scrollTo $(this).attr('href'), 500, offset: -95
    $('.active').removeClass 'active'
    $(this).addClass 'active'
  return
