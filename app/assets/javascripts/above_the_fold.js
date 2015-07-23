var navigateStagesAndLearning = function() {
  var val1=$(".progtrckr li.active .stage_name").attr("val");

  $("#stage_"+val1).fadeIn();
  $(".progtrckr li").on('click', function()
  {
    $(".progtrckr li").removeClass("active");
    $(this).addClass("active");
    var val=$(this).find(".stage_name").attr('val');
    $("#stage_imgs img").hide();
    $("#stage_"+val).fadeIn();

    // Change the stage description.
    var stageDescription = $(this).data('description');
    $('p#stage-description').fadeOut(500, function() {
      $(this).text(stageDescription).fadeIn(500);
    });
  });
};

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

$(document).ready(navigateStagesAndLearning);
$(document).ready(giveWhiteBackgroundToTopNav);
