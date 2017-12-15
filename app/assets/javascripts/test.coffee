$(document).ready =>
  if ($('body').data('env') == 'test')
    # Turn off jQuery effects / animations in the test environment.
    $.fx.off = true
