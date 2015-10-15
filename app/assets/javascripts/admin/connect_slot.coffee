multipleAddFormHandler = ->
  $('.connect-slot').click (event) ->
    slot = $(event.target)

    # Mark (or unmark) selected class.
    slot.toggleClass('selected')

    slotValue = slot.data('slot')

    if $('#connect_slots_slots').val().length
      current_slots = $('#connect_slots_slots').val().split(',')
    else
      current_slots = []

    if slot.hasClass('selected')
      # Add to slots list.
      current_slots.push(slotValue)
    else
      # Remove from slots list.
      index = current_slots.indexOf(String(slotValue))

      if index > -1
        current_slots.splice(index, 1);

    $('#connect_slots_slots').val(current_slots.join(','))

$(document).on 'page:change', ->
  $('#connect_slot_faculty_id').select2(width: '400px')
  $('#connect_slots_faculty').select2(width: '400px')

$(document).on 'page:change', multipleAddFormHandler
