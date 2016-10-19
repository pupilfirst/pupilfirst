commonOptions = { scrollInput: false, scrollMonth: false }

initializeDateTimePickers = ->
  $('.date-time-picker').each (index, element) ->
    createDateTimePicker(element)

  $('.date-picker').each (index, element) ->
    createDatePicker(element)

  $('.time-picker').each (index, element) ->
    createTimePicker(element)

formatOptions = (element) ->
  elementData = $(element).data()
  options = {}

  $.each ['format', 'minDate', 'maxDate'], (_index, property) ->
    options[property] = elementData[property]

  debugger

  options

createDateTimePicker = (element) ->
  options = {}
  $.extend(options, commonOptions, formatOptions(element))
  $(element).datetimepicker(options)

createDatePicker = (element) ->
  options = { timepicker: false }
  $.extend(options, commonOptions, formatOptions(element))
  $(element).datetimepicker(options)

createTimePicker = (element) ->
  options = { datepicker: false }
  $.extend(options, commonOptions, formatOptions(element))
  $(element).datetimepicker(options)

$(document).on('turbolinks:load', initializeDateTimePickers)
