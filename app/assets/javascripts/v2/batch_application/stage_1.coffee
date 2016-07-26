prepareCofounderFields = ->
  cofounderCountSelect = $('[name="application_stage_one[cofounder_count]"]')

  if cofounderCountSelect.length
    cofounderCountSelect.change (e) ->
      updateFee(parseInt(e.target.value))

updateFee = (cofounderCount) ->
  if isNaN(cofounderCount)
    $('.paywith-instamojo').parent().addClass('hidden-xs-up')
  else
    $('.paywith-instamojo').parent().removeClass('hidden-xs-up')
    perApplicantFee = parseInt($('#applicant-fee-data').data('applicantFee'))
    actualFee = perApplicantFee * (cofounderCount + 1)
    $('.paywith-instamojo').find('.brand-secondary').html("Rs. #{actualFee},")

$(document).on 'page:change', prepareCofounderFields
