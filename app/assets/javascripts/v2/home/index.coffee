showInstagramImageOverlays = ->
  $('.instagram-overlay').hover ->
    $(this).addClass('overlay-enabled')
  , ->
    $(this).removeClass('overlay-enabled')

$(document).on 'page:change', showInstagramImageOverlays
