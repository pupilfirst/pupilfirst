$(document).on 'page:change', ->

  $('#sidebar').stickit
    top: 100
    extraHeight: -30
  $('#sidebar ul li a').click (e) ->
    e.preventDefault()
    $.scrollTo $(this).attr('href'), 500, offset: -95
    $('.active').removeClass 'active'
    $(this).addClass 'active'
  return
