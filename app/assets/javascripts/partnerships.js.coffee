$ ->
  $("input.custom_datepicker").each (i) ->
    $(this).datepicker(format: 'dd/mm/yyyy').on 'changeDate', (e) ->
      console.log this
      console.log $(this)
      console.log $(this).next('input')
      $(this).next('input').val(e.format('yyyy-mm-dd'))
#      altFormat: "yy-mm-dd"
#      dateFormat: "dd/mm/yy"
#      altField: $(this).next()
