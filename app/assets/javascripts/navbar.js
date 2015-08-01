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

$(function() {
  if ($(".navbar-start-transparent").length) {
    $(window).scroll(toggleNavbarBackground);
  }
});
