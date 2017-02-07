toggleNavBg = ->
  $('.navbar-toggler').click ->
    $('.home-navbar').toggleClass 'toggle-bg'

$(document).on 'page:change', toggleNavBg
