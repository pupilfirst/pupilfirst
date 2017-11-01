slotsClickHandler = ->
  $('.weekly-slots__connect-slot').click (event) ->
    slot = $(event.target)
    day = slot.data('day')

    return if slot.hasClass('weekly-slots__connect-slot--requested')

    # Mark (or unmark) selected class.
    slot.toggleClass('weekly-slots__connect-slot--selected')
    slotValue = { time: parseFloat(slot.data('time')), requested: false }

    if $('#list_of_slots').val().length > 0
      currentSlots = JSON.parse($('#list_of_slots').val())
    else
      currentSlots = {}

    if slot.hasClass('weekly-slots__connect-slot--selected')
      currentSlots[day] ||= []
      currentSlots[day].push(slotValue)
    else
      index = findSlot(currentSlots[day], slotValue)

      if index > -1
        currentSlots[day].splice(index, 1);

    $('#list_of_slots').val(JSON.stringify(currentSlots))

findSlot = (list, slotValue) ->
  i = 0

  while i < list.length
    if list[i].time == slotValue.time
      return i
    i++

  -1

markPresentSlots = ->
  listOfSlots = $('#list_of_slots')

  if listOfSlots.length and listOfSlots.val().length > 0
    currentSlots = JSON.parse(listOfSlots.val())

    for day, slots of currentSlots
      for slot in slots
        slotClasses = 'weekly-slots__connect-slot--selected'
        slotClasses += ' weekly-slots__connect-slot--requested' if slot.requested
        time = slot.time
        $(".weekly-slots__connect-slot[data-day='" + day + "'][data-time='" + time.toFixed(1) + "']").addClass(slotClasses)

  addTooltipsToRequestedSlots()

addTooltipsToRequestedSlots = ->
  $('.weekly-slots__connect-slot--requested').popover
    title: 'Cannot modify'
    content: 'This slot has been requested by a founder. Please contact help@sv.co if you wish to cancel this session.'
    trigger: 'hover'
    placement: 'bottom'

$(window).on 'load', ->
  if $('#faculty-weekly-slots').length
    markPresentSlots()

$(document).on 'turbolinks:load', ->
  if $('#faculty-weekly-slots').length
    markPresentSlots()
    slotsClickHandler()
