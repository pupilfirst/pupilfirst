setupAvailabilityTooltips = ->
  facultyAvailability = $('.faculty-availability')
  facultyAvailability.find('span.badge').tooltip()
  facultyAvailability.find('a').tooltip()

$(setupAvailabilityTooltips)
