//= require jquery.flexslider
//= require owl-carousel/owl.carousel
//= require ct-carousel/masonry.pkgd.min
//= require icon/modernizr.custom
//= require homepage/stages

function stripHTML(dirtyString) {
  var container = document.createElement('div');
  container.innerHTML = dirtyString;
  return container.textContent || container.innerText;
}

var loadBlogPosts = function() {
  // TODO: Load JS and images from https://blog.sv.co when it's available.
  $.get("http://www.startatsv.com?json=get_recent_posts&count=4", function(data) {
    var blogPostsContainer = $("#blog-posts-container");
    var postScaffold = $("#post-scaffold");

    $.each(data.posts, function(postIndex, post) {
      var postClone = postScaffold.clone();

      // Make it a regular post.
      postClone.removeAttr('id');

      // Add post title, image, content and link.
      postClone.find('.blog-post-image').attr('src', post.thumbnail_images.full.url);
      postClone.find('.blog-post-title').html(post.title_plain);

      // Reduce length of post content if title is long.
      var contentLength = post.title_plain.length > 30 ? (220 - Math.round((post.title_plain.length - 30) * 1.2)) : 210;
      postClone.find('.blog-post-content').html(stripHTML(post.content).substring(0, contentLength) + "...");

      postClone.find('.blog-post-link').attr('href', post.url);

      // Unhide the post, and append it to list of posts.
      postClone.removeClass('hide');
      postClone.appendTo(blogPostsContainer);
    });
  }, "jsonp").fail(function() {
    // Show the failed text.
    $("#blog-posts-loading-failed").removeClass('hide');
  }).always(function () {
    // Hide the loading text.
    $("#blog-posts-loading").addClass('hide');
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
  $("#get-funded").addClass("story-clicked");
  $("#get-funded-stories").fadeIn(400);
  $('.list-item').click(function(){
    $('.showcase-stories').fadeOut(200);
    $('.list-item').removeClass("story-clicked");
    pauseAllVideos();
  });
  $("#get-funded-stories").click(function(){
    pauseAllVideos();
  });
  $("#get-funded").click(function(){
    $("#get-funded-stories").fadeIn(400);
    $("#get-funded").addClass("story-clicked");
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
};

var pauseAllVideos = function(){
  pauseVideoWithId("iTraveller-story");
  pauseVideoWithId("fin-story");
  pauseVideoWithId("reckone-story");
  pauseVideoWithId("profoundis-story");
  pauseVideoWithId("Mindhelix-story");
  pauseVideoWithId("wowmakers-story");
};

var pauseVideoWithId = function (videoId){
  var div = document.getElementById(videoId);
  var iframe = div.getElementsByTagName("iframe")[0].contentWindow;
  iframe.postMessage('{"event":"command","func":"' + 'pauseVideo' + '","args":""}', '*');
};

$(document).ready(swapSuccessStories);
$(document).ready(startupsShowcaseSlide);
$(document).ready(storiesSlide);
$(document).ready(mediaShowcaseSlide);
$(document).ready(prepareTestimonials);
$(document).ready(loadBlogPosts);

$(document).ready(function() {
  [].slice.call(document.querySelectorAll('.carousel-indicators > ol')).forEach(function(nav) {
    new DotNav(nav, {
      callback : function( idx ) {
        //console.log( idx )
      }
    });
  });
});
