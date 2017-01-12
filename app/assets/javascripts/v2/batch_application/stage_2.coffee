prepareTeamSizeField = ->
  cofounderCountSelect = $('[name="batch_applications_payment[team_size]"]')

  if cofounderCountSelect.length
    showOrHidePaymentButton(cofounderCountSelect.val())

    cofounderCountSelect.change (e) ->
      showOrHidePaymentButton(e.target.value)

showOrHidePaymentButton = (cofounderCountSelectValue) ->
  if cofounderCountSelectValue.length > 0
    $('.paywith-instamojo').parent().removeClass('hidden-xs-up')
  else
    $('.paywith-instamojo').parent().addClass('hidden-xs-up')

$(document).on 'turbolinks:load', ->
  if $('#batch-application__stage-2').length > 0
    prepareTeamSizeField()
