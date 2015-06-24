$(function(){
    var ink, d, x, y;
    $(".tl_link_button").click(function(e){
    if($(this).find(".ink").length === 0){
        $(this).prepend("<span class='ink'></span>");
    }

    ink = $(this).find(".ink");
    ink.removeClass("animate");

    if(!ink.height() && !ink.width()){
        d = Math.max($(this).outerWidth(), $(this).outerHeight());
        ink.css({height: d, width: d});
    }

    x = e.pageX - $(this).offset().left - ink.width()/2;
    y = e.pageY - $(this).offset().top - ink.height()/2;

    ink.css({top: y+'px', left: x+'px'}).addClass("animate");
});
});


$(document).ready(function () {
          $('#read-from-beginning').click(function () {
            $('html, body').animate({scrollTop: $(document).height()}, 'slow');
            return false;
          });

          if($(window).width()<767)
          {
            $("#verified").removeClass("tooltip-right");
            $("#verified").removeAttr("data-tooltip");
          }

          $(window).resize(function(){
              if($(window).width()<767)
          {
            $("#verified").removeClass("tooltip-right");
            $("#verified").removeAttr("data-tooltip");
          }
          });

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



        });
