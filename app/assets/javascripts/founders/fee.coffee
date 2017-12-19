handleCouponFormVisibility = ->
  $('#coupon-form-show').click(toggleCouponForm)
  $('#coupon-form-hide').click(toggleCouponForm)

  if $('.admissions_coupon_code.has-error').length
    toggleCouponForm()

toggleCouponForm = ->
  $('#coupon-form').toggleClass('d-none')
  $('#coupon-form-hide').toggleClass('d-none')
  $('#coupon-form-show').toggleClass('d-none')

handleFeeSubmit = ->
  $('.js-founder-fee__form').on 'ajax:before', (event) ->
    $('.js-founder-fee__pay-button').addClass('d-none')
    $(event.target).siblings('.js-founder-fee__disabled-pay-button').removeClass('d-none')

  $('.js-founder-fee__form').on 'ajax:success', (event) ->
    Instamojo.open(event.detail[0].long_url);
    $(event.target).siblings('.js-founder-fee__disabled-pay-button').addClass('d-none')
    $('.js-founder-fee__pay-button').removeClass('d-none')

  $('.js-founder-fee__form').on 'ajax:error', (event) ->
    formElement = $(event.target)
    formElement.siblings('.js-founder-fee__disabled-pay-button').find('button').html('<i class="fa fa-warning"/> Error')
    formElement.siblings('.fee-offer__error').removeClass('d-none')


$(document).on 'turbolinks:load', ->
  if $('#founder__fee').length
    handleCouponFormVisibility()
    handleFeeSubmit()
