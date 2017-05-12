handleCouponFormVisibility = ->
  $('#coupon-form-show').click(toggleCouponForm)
  $('#coupon-form-hide').click(toggleCouponForm)

  if $('.admissions_coupon_code.has-error').length
    toggleCouponForm()

toggleCouponForm = ->
  $('#coupon-form').toggleClass('hidden-xs-up')
  $('#coupon-form-hide').toggleClass('hidden-xs-up')
  $('#coupon-form-show').toggleClass('hidden-xs-up')

$(document).on 'turbolinks:load', ->
  if $('#admissions__fee').length
    handleCouponFormVisibility()
