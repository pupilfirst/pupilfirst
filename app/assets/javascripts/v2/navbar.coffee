# Hide Header on scroll down and Show on scroll up
didScroll = undefined
lastScrollTop = 0
delta = 75
navbarHeight = $('.navbar').outerHeight()

hasScrolled = ->
  st = $(this).scrollTop()
  # Make sure they scroll more than delta
  if Math.abs(lastScrollTop - st) <= delta
    return
  # If they scrolled down and are past the navbar, add class .nav-up.
  # This is necessary so you never see what is "behind" the navbar.
  if st > lastScrollTop and st > navbarHeight
    # Scroll Down
    $('.navbar').removeClass('nav-down').addClass 'nav-up'
  else
    # Scroll Up
    if st + $(window).height() < $(document).height()
      $('.navbar').removeClass('nav-up').addClass 'nav-down'
  lastScrollTop = st

$(window).scroll (event) ->
  didScroll = true
setInterval (->
  if didScroll
    hasScrolled()
    didScroll = false
  ), 250
