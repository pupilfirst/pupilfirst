setupAvailabilityTooltips = ->
  $('.available-marker').tooltip()
  $('.connect-link').tooltip()


$(document).on('ready page:load', setupAvailabilityTooltips)
