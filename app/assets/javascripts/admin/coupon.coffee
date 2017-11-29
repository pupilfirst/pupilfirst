confirmCouponFormSubmission = ->
  $('form#edit_coupon').submit (event)->
    event.preventDefault()

    if confirm 'Did you read the warning? Are you sure you want to make changes to this coupon?'
      event.target.submit()
    else
      false

$(document).on 'turbolinks:load', ->
  if $('#admin-coupon__form').length > 0 && $('.admin-coupon__update-warning').length > 0
    confirmCouponFormSubmission()
