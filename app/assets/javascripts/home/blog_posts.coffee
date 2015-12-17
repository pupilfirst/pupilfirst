stripHTML = (dirtyString) ->
  container = document.createElement('div')
  container.innerHTML = dirtyString;
  container.textContent || container.innerText;

loadBlogPosts = ->
  # Don't do anything unless we're on the home page.
  return unless $('#blog-posts-container').length

  # TODO: Load JS and images from https://blog.sv.co when it's available.
  $.get("https://blog.sv.co?json=get_recent_posts&count=4", (data) ->
    blogPostsContainer = $("#blog-posts-container")
    postScaffold = $("#post-scaffold")

    $.each data.posts, (postIndex, post) ->
      postClone = postScaffold.clone()

      # Make it a regular post.
      postClone.removeAttr 'id'

      # Add image tag.
      blogPostImage = document.createElement 'img'
      blogPostImage.src = post.thumbnail_images.full.url
      blogPostImage.className = 'blog-post-image'
      postClone.find('.blog-post-image-link').prepend(blogPostImage)

      # Add title.
      postClone.find('.blog-post-title').html(post.title_plain)

      # Reduce length of post content if title is long.
      contentLength = if (post.title_plain.length > 30) then (220 - Math.round((post.title_plain.length - 30) * 1.2)) else 210
      postClone.find('.blog-post-content').html(stripHTML(post.content).substring(0, contentLength) + "...")

      # Add link to continue button, post image and post title
      postClone.find('.blog-post-image-link').attr('href', post.url)
      postClone.find('.blog-post-link').attr('href', post.url)
      postClone.find('.blog-post-title-link').attr('href', post.url)

      # Unhide the post, and append it to list of posts.
      postClone.removeClass('hidden')
      postClone.appendTo(blogPostsContainer)
  , "jsonp").fail(->
    # Show the failed text.
    $("#blog-posts-loading-failed").removeClass('hidden')
  ).always(->
    # Hide the loading text.
    $("#blog-posts-loading").addClass('hidden')
  ) unless $('.blog-post:not(.hidden)').length > 0

$(document).on 'page:change', loadBlogPosts
