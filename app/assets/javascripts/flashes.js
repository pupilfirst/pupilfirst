$(window).bind('rails:flash', function(e, params) {
  new PNotify({
    title: (params.type.charAt(0).toUpperCase() + params.type.substring(1)),
    text: params.message,
    type: params.type,
    mouse_reset: false,
    styling: 'fontawesome'
  });
});
