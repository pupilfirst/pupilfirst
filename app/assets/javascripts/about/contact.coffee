activateMapsOnClick = ->
  $('.google-maps-iframe-container').click ->
    $('.google-maps-iframe-container iframe').css('pointer-events', 'auto')

  $('.google-maps-iframe-container').mouseleave ->
    $('.google-maps-iframe-container iframe').css('pointer-events', 'none')


$(document).on 'page:change', activateMapsOnClick
