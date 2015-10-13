# Shift the window to account for height of fixed navbar.
shiftWindow = ->
  scrollBy(0, -80)

window.addEventListener("hashchange", shiftWindow)

$(window).load ->
  if location.hash
    shiftWindow()

$(document).on 'page:change', ->
  if location.hash
    shiftWindow()
