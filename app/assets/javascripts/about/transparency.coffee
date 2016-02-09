$(document).on 'page:change', ->

  $('#sidebar').stickit({
    top: 100,
    extraHeight: -30
    });
  $('#sidebar ul li a').click (e) ->
    e.preventDefault()
    $.scrollTo $(this).attr('href'), 500
    $('.active').removeClass 'active'
    $(this).parent().addClass 'active'
  return
