$(document).on('ready page:load', function() {
  $(window).bind('rails:flash', function(e, params) {
    new PNotify({
      title: (params.type.charAt(0).toUpperCase() + params.type.substring(1)),
      text: params.message,
      type: params.type,
      mouse_reset: false,
      styling: 'jqueryui',
      addclass: 'active-admin-notification',
      nonblock: {
        nonblock: true,
        nonblock_opacity: .2
      }
    });
  });
});
