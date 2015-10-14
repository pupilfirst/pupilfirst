setupAvailabilityTooltips = ->
  $('.available-marker').tooltip()
  $('.connect-link').tooltip()

$(document).on 'page:change', setupAvailabilityTooltips
