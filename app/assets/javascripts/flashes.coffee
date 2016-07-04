$(window).bind 'rails:flash', (e, params) ->
  new PNotify
    title: (params.type.charAt(0).toUpperCase() + params.type.substring(1)).split('_').join(' '),
    text: params.message,
    type: params.type,
    mouse_reset: false,
#    styling: 'fontawesome',
    buttons: { sticker: false }
