handleCouponFormVisibility = ->
  $('#coupon-form-show').click ->
    $('#coupon-form').removeClass('hidden-xs-up')
    $('#coupon-form-hide').removeClass('hidden-xs-up')
    $('#coupon-form-show').addClass('hidden-xs-up')

  $('#coupon-form-hide').click ->
    $('#coupon-form').addClass('hidden-xs-up')
    $('#coupon-form-hide').addClass('hidden-xs-up')
    $('#coupon-form-show').removeClass('hidden-xs-up')

$(document).on 'turbolinks:load', ->
  if $('#admissions__fee').length
    handleCouponFormVisibility()
