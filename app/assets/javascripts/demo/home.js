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
  $(window).scroll(function()
  {
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

$(document).ready(navigateStagesAndLearning);
$(document).ready(giveWhiteBackgroundToTopNav);

$(document).ready(function() {
  [].slice.call( document.querySelectorAll( '.carousel-indicators > ol' ) ).forEach( function( nav ) {
    new DotNav( nav, {
      callback : function( idx ) {
        //console.log( idx )
      }
    } );
  } );
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

$(document).ready(function() {

  $("#owl-demo1").owlCarousel({

    navigation : true,
    navigationText: [
      "<img src='img/arrow2_l.png'/>",
      "<img src='img/arrow2_r.png'/>"
    ],// Show next and prev buttons
    slideSpeed : 300,
    paginationSpeed : 400,
    singleItem:true

    // "singleItem:true" is a shortcut for:
    // items : 1,
    // itemsDesktop : false,
    // itemsDesktopSmall : false,
    // itemsTablet: false,
    // itemsMobile : false

  });

});

$(document).ready(function ()
{
  var carousel = $("#owl-demo");
  carousel.owlCarousel({
    navigation:true,
    pagination:true,
    navigationText: [
      "<img src='img/arrow2_l.png'/>",
      "<img src='img/arrow2_r.png'/>"
    ],
  });


});

$(document).ready(function() {

  var h1=$("#owl-demo1 .item").height();
  var h2=$("#owl-demo1 .owl-next img").height();
  var h2_new=Math.round(h2/2);
  var h1_new=Math.round(h1/2);
  var new_h=h1_new-h2_new;
  //alert(new_h);
  $("#owl-demo1 .owl-next img").css({"margin-top":"81px !important", "position":"relative"});
  //$("#owl-demo1 .owl-next img").hide();

});
