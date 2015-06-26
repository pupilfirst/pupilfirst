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
  $('#inline-popups').magnificPopup({
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
    animation: "slide",
    controlNav: false,
    slideshow: false,
    smoothHeight: true,
    start: function(){
      $('.cd-testimonials').children('li').css({
        'opacity': 1,
        'position': 'relative'
      });
    }
  });

  //open the testimonials modal page
  $('.cd-see-all').on('click', function(){
    $('.cd-testimonials-all').addClass('is-visible');
  });

  //close the testimonials modal page
  $('.cd-testimonials-all .close-btn').on('click', function(){
    $('.cd-testimonials-all').removeClass('is-visible');
  });
  $(document).keyup(function(event){
    //check if user has pressed 'Esc'
    if(event.which=='27'){
      $('.cd-testimonials-all').removeClass('is-visible');
    }
  });

  //build the grid for the testimonials modal page
  $('.cd-testimonials-all-wrapper').children('ul').masonry({
    itemSelector: '.cd-testimonials-item'
  });
};

$(document).ready(navigateStagesAndLearning);
$(document).ready(giveWhiteBackgroundToTopNav);
$(document).ready(popupStartupTimeline);
$(document).ready(startupsShowcaseSlide);
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

$(document).ready(function() {
  var hash = window.location.hash,
    current = 0,
    demos = Array.prototype.slice.call( document.querySelectorAll( '#codrops-demos > a' ) );

  if( hash === '' ) hash = '#set-1';
  setDemo( demos[ parseInt( hash.match(/#set-(\d+)/)[1] ) - 1 ] );

  demos.forEach( function( el, i ) {
    el.addEventListener( 'click', function() { setDemo( this ); } );
  } );

  function setDemo( el ) {
    var idx = demos.indexOf( el );
    if( current !== idx ) {
      var currentDemo = demos[ current ];
      currentDemo.className = currentDemo.className.replace(new RegExp("(^|\\s+)" + 'current-demo' + "(\\s+|$)"), ' ');
    }
    current = idx;
    el.className = 'current-demo';
  }
});
