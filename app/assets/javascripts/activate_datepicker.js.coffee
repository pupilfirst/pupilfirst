activate_datepicker = ->
  $("input.custom_datepicker").each (i) ->
    $(this).datepicker(format: 'dd/mm/yyyy').on 'changeDate', (e) ->
      $(this).next('input').val(e.format('yyyy-mm-dd'))

$ -> activate_datepicker()
$(document).on('page:load', activate_datepicker)