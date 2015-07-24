var toggleNavbarBackground = function() {
  if ($(document).scrollTop() > 50)
  {
    $("#SiteLogoWhite").stop(true, true).hide();
    $("#SiteLogo").removeClass('hide').fadeIn();
    $('nav').addClass('shrink');
  } else {
    $("#SiteLogo").stop(true, true).hide();
    $("#SiteLogoWhite").fadeIn();
    $('nav').removeClass('shrink');
  }
};

$(function() {
  if ($(".navbar-start-transparent").length) {
    $(window).scroll(toggleNavbarBackground);
  }
});
