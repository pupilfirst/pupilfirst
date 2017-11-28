toggleNavBg = ->
  $('.navbar-toggler').click ->
    $('.home-header').toggleClass 'toggle-bg'

$(document).on 'page:change', toggleNavBg
