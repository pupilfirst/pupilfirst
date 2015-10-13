toggleNavbarBackground = ->
  if $(document).scrollTop() > 50
    $("#site-logo-white").stop(true, true).hide()
    $("#site-logo").removeClass('hide').fadeIn()
    $('nav').addClass('shrink')
  else
    $("#site-logo").stop(true, true).hide()
    $("#site-logo-white").fadeIn()
    $('nav').removeClass('shrink')

$(document).on 'page:change', ->
  if $(".navbar-start-transparent").length
    $(window).scroll(toggleNavbarBackground)
  else
    $(window).off("scroll", toggleNavbarBackground);

# Enable the progressbar that shows up at top of page. This needs to be done only once per session.
# TODO: Remove this when upgrading to Rails 5 (Turbolinks 3), where this progressbar is active by default.
$ ->
  Turbolinks.enableProgressBar();
