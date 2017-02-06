copyToClipboard = ->
  $('.coupon-share__copy').click ->
    copyField = $('.coupon-share__copy-field')
    copyField.addClass('coupon-share__copy-field--visible')
    copyField.val($('.coupon-box').text())
    copyField.select()
    document.execCommand('copy')
    copyField.removeClass('coupon-share__copy-field--visible')

    new PNotify
      title: 'Copied!',
      text: 'The coupon code has been copied to your clipboard.',
      type: 'success',
      mouse_reset: false,
      buttons: {sticker: false}

$(document).on 'turbolinks:load', ->
  if $('.coupon-share__copy-field').length > 0
    copyToClipboard()
