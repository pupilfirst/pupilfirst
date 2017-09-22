handleCouponFormVisibility = ->
  $('#coupon-form-show').click(toggleCouponForm)
  $('#coupon-form-hide').click(toggleCouponForm)

  if $('.admissions_coupon_code.has-error').length
    toggleCouponForm()

toggleCouponForm = ->
  $('#coupon-form').toggleClass('hidden-xs-up')
  $('#coupon-form-hide').toggleClass('hidden-xs-up')
  $('#coupon-form-show').toggleClass('hidden-xs-up')

handleFeeSubmit = ->
  $('.js-founder-fee__form').on 'ajax:before', (event) ->
    $('.js-founder-fee__pay-button').addClass('hidden-xs-up')
    $(event.target).siblings('.js-founder-fee__disabled-pay-button').removeClass('hidden-xs-up')

  $('.js-founder-fee__form').on 'ajax:success', (event) ->
    Instamojo.open(event.detail[0].long_url);
    $(event.target).siblings('.js-founder-fee__disabled-pay-button').addClass('hidden-xs-up')
    $('.js-founder-fee__pay-button').removeClass('hidden-xs-up')

  $('.js-founder-fee__form').on 'ajax:error', (event) ->
    formElement = $(event.target)
    formElement.siblings('.js-founder-fee__disabled-pay-button').find('button').html('<i class="fa fa-warning"/> Error')
    formElement.siblings('.fee-offer__error').removeClass('hidden-xs-up')


$(document).on 'turbolinks:load', ->
  if $('#founder__fee').length
    handleCouponFormVisibility()
    handleFeeSubmit()
