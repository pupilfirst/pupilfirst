# Setup PNotify
$(window).bind 'rails:flash', (e, params) ->
  new PNotify
    title: (params.type.charAt(0).toUpperCase() + params.type.substring(1)).split('_').join(' '),
    text: params.message,
    type: params.type,
    mouse_reset: false,
    buttons: { sticker: false }

select2Initializations = ->
  $('#q_product_name').select2(width: '100%');

# Manually link site_title logo to /admin as activeskin messes up setting config.site_title_link
$(document).on 'page:change', ->
  $('#site_title').click (event) ->
    location.href = 'https://www.sv.co/admin'

$(document).on 'page:change', select2Initializations
