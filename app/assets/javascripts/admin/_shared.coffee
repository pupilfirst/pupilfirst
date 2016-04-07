# Setup PNotify
$(window).bind 'rails:flash', (e, params) ->
  new PNotify
    title: (params.type.charAt(0).toUpperCase() + params.type.substring(1)),
    text: params.message,
    type: params.type,
    mouse_reset: false,
    styling: 'jqueryui',
    addclass: 'active-admin-notification',
    nonblock:
      nonblock: true,
      nonblock_opacity: .2

# Enable the progressbar that shows up at top of page. This needs to be done only once per session.
# TODO: Remove this when upgrading to Rails 5 (Turbolinks 3), where this progressbar is active by default.
$ ->
  Turbolinks.enableProgressBar();

select2Initializations = ->
  $('#q_ransack_tagged_with').select2(width: '100%');
  $('#q_product_name').select2(width: '100%');

# Manually link site_title logo to /admin as activeskin messes up setting config.site_title_link
$(document).on 'page:change', ->
  $('#site_title').click (event) ->
    location.href = 'https://www.sv.co/admin'

$(document).on 'page:change', select2Initializations
