$(window).bind 'rails:flash', (e, params) ->
  notice = new PNotify
    title: (params.type.charAt(0).toUpperCase() + params.type.substring(1)).split('_').join(' '),
    text: params.message,
    type: params.type,
    mouse_reset: false,
    buttons: {sticker: false, closer: false}

  notice.get().click ->
    notice.remove()
