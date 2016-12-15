commonOptions = { scrollInput: false, scrollMonth: false, format: 'Y-m-d' }

initializeDateTimePickers = (rootSelector) ->
  rootSelector ?= $('body')

  rootSelector.find('.date-time-picker').each (index, element) ->
    createDateTimePicker(element)

  rootSelector.find('.date-picker').each (index, element) ->
    createDateTimePicker(element, timepicker: false)

  rootSelector.find('.time-picker').each (index, element) ->
    createDateTimePicker(element, datepicker: false)

formatOptions = (element) ->
  elementData = $(element).data()
  options = {}

  $.each ['format', 'minDate', 'maxDate', 'step', 'allowTimes', 'defaultTime'], (_index, property) ->
    options[property] = elementData[property]

  options

createDateTimePicker = (element, pickerOptions = {}) ->
  $.extend(pickerOptions, commonOptions, formatOptions(element))
  inputField = $(element)
  inputField.datetimepicker(pickerOptions)
  inputField.data('datePickerInitialized', 'true')

# This will setup datetimepickers on input elements added by AA's nested form handlers.
initializeDateTimePickersOnNestedElements = ->
  $(document).on 'has_many_add:after', '.has_many_container', (_e, fieldset)->
    initializeDateTimePickers(fieldset)

$(document).on 'turbolinks:load', ->
  initializeDateTimePickers()
  initializeDateTimePickersOnNestedElements()
