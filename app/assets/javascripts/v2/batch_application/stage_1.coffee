prepareCofounderFields = ->
  cofounderCountSelect = $('[name="application_stage_one[cofounder_count_select]"]')

  if cofounderCountSelect.length
    showOrHidePaymentButton(cofounderCountSelect.val())

    cofounderCountSelect.change (e) ->
      showOrHidePaymentButton(e.target.value)

showOrHidePaymentButton = (cofounderCountSelectValue) ->
  if cofounderCountSelectValue.length > 0
    $('.paywith-instamojo').parent().removeClass('hidden-xs-up')
  else
    $('.paywith-instamojo').parent().addClass('hidden-xs-up')

toggleCofounderCountFieldOnChange = ->
  cofounderCountSelectInput = $('#application_stage_one_cofounder_count_select')

  if cofounderCountSelectInput.val() == 'More than 4 (Enter number)'
    cofounderCountNumberInput = $('#application_stage_one_cofounder_count_number')
    cofounderCountNumberInput.prop('disabled', false)
    cofounderCountNumberInput.parent().parent().parent().removeClass('hidden-xs-up')
    cofounderCountSelectInput.parent().parent().addClass('hidden-xs-up')
    cofounderCountNumberInput.focus()

toggleCofounderCountFieldOnLoad = ->
  if $('#application_stage_one_cofounder_count_select').length
    toggleCofounderCountFieldOnChange()
    $('#application_stage_one_cofounder_count_select').change toggleCofounderCountFieldOnChange

$(document).on 'page:change', prepareCofounderFields
$(document).on 'page:change', toggleCofounderCountFieldOnLoad
