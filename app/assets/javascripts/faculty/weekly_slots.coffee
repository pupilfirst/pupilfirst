slotsClickHandler = ->
  $('.connect-slot').click (event) ->
    slot = $(event.target)

    # Mark (or unmark) selected class.
    slot.toggleClass('selected')

$(document).on 'page:change', slotsClickHandler
