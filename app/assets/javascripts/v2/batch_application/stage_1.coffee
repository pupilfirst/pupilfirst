prepareCofounderFields = ->
  cofounderCountSelect = $('[name="application_stage_one[cofounder_count]"]')

  if cofounderCountSelect.length
    showOrHidePaymentButton(parseInt(cofounderCountSelect.val()))

    cofounderCountSelect.change (e) ->
      showOrHidePaymentButton(parseInt(e.target.value))

showOrHidePaymentButton = (cofounderCount) ->
  if isNaN(cofounderCount)
    $('.paywith-instamojo').parent().addClass('hidden-xs-up')
  else
    $('.paywith-instamojo').parent().removeClass('hidden-xs-up')

stickCodeVideoSubmitForm = ->
  $('#code-video-submit').stickit
    top: 0,
    screenMinWidth: 1024

$(document).on 'page:change', prepareCofounderFields
$(document).on 'page:change', stickCodeVideoSubmitForm
