//= require owl-carousel/owl.carousel
//= require ct-carousel/masonry.pkgd.min
//= require icon/modernizr.custom

//= require_tree ./homepage

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

$(loadBlogPosts);

//TODO: What is this for?
$(document).ready(function() {
  [].slice.call(document.querySelectorAll('.carousel-indicators > ol')).forEach(function(nav) {
    new DotNav(nav, {
      callback : function( idx ) {
        //console.log( idx )
      }
    });
  });
});
