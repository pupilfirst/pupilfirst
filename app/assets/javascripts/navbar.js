var toggleNavbarBackground = function() {
  if ($(document).scrollTop() > 50)
  {
    $("#site-logo-white").stop(true, true).hide();
    $("#site-logo").removeClass('hide').fadeIn();
    $('nav').addClass('shrink');
  } else {
    $("#site-logo").stop(true, true).hide();
    $("#site-logo-white").fadeIn();
    $('nav').removeClass('shrink');
  }
};

$(document).on('page:change', function() {
  if ($(".navbar-start-transparent").length) {
    $(window).scroll(toggleNavbarBackground);
  }
});

// Shift the window to account for height of fixed navbar.
var shiftWindow = function() { scrollBy(0, -80) };
window.addEventListener("hashchange", shiftWindow);

$(window).load(function() {
  if (location.hash) shiftWindow();
});

$(document).on('page:change', function() {
  if (location.hash) shiftWindow();
});
