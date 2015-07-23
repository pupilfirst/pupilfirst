var giveWhiteBackgroundToTopNav = function() {
  $(window).scroll(function() {
    if ($(document).scrollTop() > 300)
    {
      var siteLogoWhite = $("#SiteLogoWhite");
      var siteLogoColor = $("#SiteLogo");
      siteLogoWhite.stop(true, true).hide();
      siteLogoColor.removeClass('hide').fadeIn();
      $('nav').addClass('shrink');
    } else {
      $("#SiteLogo").stop(true, true);
      $("#SiteLogo").hide();
      $("#SiteLogoWhite").fadeIn();
      $('nav').removeClass('shrink');
    }
  });
};

$(document).ready(giveWhiteBackgroundToTopNav);
