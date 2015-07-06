$(window).scroll(function() {
  if ($(document).scrollTop() > 450)
  {
    $("#sp_nav").addClass("fixit");
  } else {
    $("#sp_nav").removeClass('fixit');
  }
});

if ($(document).scrollTop() > 450) {
  $("#sp_nav").addClass("fixit");
} else {
  $("#sp_nav").removeClass('fixit');
}

/*Url jumping*/
$(function() {
  $('a[href*=#]:not([href=#])').click(function() {
    if (location.pathname.replace(/^\//, '') == this.pathname.replace(/^\//, '') && location.hostname == this.hostname) {
      var target = $(this.hash);
      target = target.length ? target : $('[name=' + this.hash.slice(1) + ']');
      if (target.length) {
        $('html,body').animate({
          scrollTop: target.offset().top
        }, 1000);
        return false;
      }
    }
  });
});

$(document).ready(function() {
  $('body').scrollspy(
    {
      target: '.startups_nav',
      offset:'200'
    }
  );
});


var giveWhiteBackgroundToTopNav = function() {
  $(window).scroll(function() {
    if ($(document).scrollTop() > 300)
    {
      $("#SiteLogoWhite").hide();
      $("#SiteLogo").fadeIn();
      $('nav').addClass('shrink');
    } else {
      $("#SiteLogo").hide();
      $("#SiteLogoWhite").fadeIn();
      $('nav').removeClass('shrink');
    }
  });
};

$(document).ready(giveWhiteBackgroundToTopNav);

