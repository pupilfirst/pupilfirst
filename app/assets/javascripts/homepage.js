//= require jquery.flexslider

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

var popupStartupTimeline = function() {
  $('.inline-popups').magnificPopup({
    delegate: 'a',
    removalDelay: 500, //delay removal by X to allow out-animation
    callbacks: {
      beforeOpen: function () {
        this.st.mainClass = this.st.el.attr('data-effect');
      }
    },
    midClick: true // allow opening popup on middle mouse click. Always set it to true if you don't provide alternative source.
  });
};

var startupsShowcaseSlide = function() {
  var dataFromView = $("#startups-showcase-data");

  $("#owl-demo1").owlCarousel({
    navigation : true,
    navigationText: [
      "<img src='" + dataFromView.data('arrow-left-url') + "'/>",
      "<img src='" + dataFromView.data('arrow-right-url') + "'/>"
    ],// Show next and prev buttons
    slideSpeed : 300,
    paginationSpeed : 400,
    singleItem:true
  });
};

var storiesSlide = function() {
  var dataFromView = $("#startups-showcase-data");// using the same arrows

  $(".stories-carousel").owlCarousel({
    navigation : true,
    navigationText: [
      "<img src='" + dataFromView.data('arrow-left-url') + "'/>",
      "<img src='" + dataFromView.data('arrow-right-url') + "'/>"
    ],// Show next and prev buttons
    slideSpeed : 300,
    paginationSpeed : 400,
    singleItem:true
  });
};

var mediaShowcaseSlide = function() {
  var dataFromView = $("#media-showcase-data");
  var carousel = $("#owl-demo");

  carousel.owlCarousel({
    navigation:true,
    pagination:true,
    navigationText: [
      "<img src='" + dataFromView.data('arrow-left-url') + "'/>",
      "<img src='" + dataFromView.data('arrow-right-url') + "'/>"
    ]
  });
};

var prepareTestimonials = function() {
  //create the slider
  $('.cd-testimonials-wrapper').flexslider({
    selector: ".cd-testimonials > li",
    //animation: "slide",
    controlNav: false,
    //slideshow: false,
    //smoothHeight: true,
    //start: function(){
    //  $('.cd-testimonials').children('li').css({
    //    'opacity': 1,
    //    'position': 'relative'
    //  });
    //}
  });
};

// Function to swap success stories for different success scenarios
var swapSuccessStories = function(){
  $('.showcase-stories').hide();
  $("#get-funded-stories").fadeIn(400);
  $('.list-item').click(function(){
    $('.showcase-stories').fadeOut(200);
    $('.list-item').removeClass("story-clicked");
  });
  $("#get-funded").click(function(){
    $("#get-funded-stories").fadeIn(400);
    $("#get-funded").addClass("story-clicked");
    // $("#get-funded-stories")[0].scrollIntoView({block: "end", behavior: "smooth"});
  });
  $("#get-accelerator").click(function(){
    $("#accelerator-stories").fadeIn(400);
    $("#get-accelerator").addClass("story-clicked");
    // $("#accelerator-stories")[0].scrollIntoView({block: "end", behavior: "smooth"});
  });
  $("#get-hired").click(function(){
    $("#get-hired-stories").fadeIn(400);
    $("#get-hired").addClass("story-clicked");
    // $("#get-hired-stories")[0].scrollIntoView({block: "end", behavior: "smooth"});
  });
  $("#get-sustain").click(function(){
    $("#self-sustain-stories").fadeIn(400);
    $("#get-sustain").addClass("story-clicked");
    // $("#self-sustain-stories")[0].scrollIntoView({block: "end", behavior: "smooth"});
  });
  $("#get-job").click(function(){
    $("#Nwplyng-story").fadeIn(400);
    $("#get-job").addClass("story-clicked");
    // $("#Nwplyng-story")[0].scrollIntoView({block: "end", behavior: "smooth"});
  });
  $("#get-education").click(function(){
    $("#Sharan-story").fadeIn(400);
    $("#get-education").addClass("story-clicked");
    // $("#Sharan-story")[0].scrollIntoView({block: "end", behavior: "smooth"});
  });
}

$(document).ready(swapSuccessStories);
$(document).ready(navigateStagesAndLearning);
$(document).ready(giveWhiteBackgroundToTopNav);
$(document).ready(popupStartupTimeline);
$(document).ready(startupsShowcaseSlide);
$(document).ready(storiesSlide);
$(document).ready(mediaShowcaseSlide);
$(document).ready(prepareTestimonials);


$(document).ready(function() {
  [].slice.call(document.querySelectorAll('.carousel-indicators > ol')).forEach(function(nav) {
    new DotNav(nav, {
      callback : function( idx ) {
        //console.log( idx )
      }
    });
  });
});
