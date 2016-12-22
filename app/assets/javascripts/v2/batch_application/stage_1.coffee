prepareCofounderFields = ->
  cofounderCountSelect = $('[name="application_stage_one[team_size_select]"]')

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
  cofounderCountSelectInput = $('#application_stage_one_team_size_select')

  if cofounderCountSelectInput.val() == 'More than 5 (Enter number)'
    cofounderCountNumberInput = $('#application_stage_one_team_size_number')
    cofounderCountNumberInput.prop('disabled', false)
    cofounderCountNumberInput.parent().parent().parent().removeClass('hidden-xs-up')
    cofounderCountSelectInput.parent().parent().addClass('hidden-xs-up')
    cofounderCountNumberInput.focus()

toggleCofounderCountFieldOnLoad = ->
  if $('#application_stage_one_team_size_select').length
    toggleCofounderCountFieldOnChange()
    $('#application_stage_one_team_size_select').change toggleCofounderCountFieldOnChange

stickCodeVideoSubmitForm = ->
  $('#code-video-submit').stickit
    top: 0,
    screenMinWidth: 1024

$(document).on 'page:change', prepareCofounderFields
$(document).on 'page:change', toggleCofounderCountFieldOnLoad

$(document).on 'turbolinks:load', ->
  if $('#code-video-submit').length > 0
    stickCodeVideoSubmitForm()
