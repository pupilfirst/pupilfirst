hideIntercomOnSmallScreen = ->
  window.Intercom('shutdown') if window.innerWidth < 576

$(document).on 'turbolinks:load', ->
  if $('.target-overlay__overlay').length
    hideIntercomOnSmallScreen()
