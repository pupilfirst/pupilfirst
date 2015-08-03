stripHTML = (dirtyString) ->
  container = document.createElement('div')
  container.innerHTML = dirtyString;
  container.textContent || container.innerText;

loadBlogPosts = ->
  # TODO: Load JS and images from https://blog.sv.co when it's available.
  $.get("http://www.startatsv.com?json=get_recent_posts&count=4", (data) ->
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
      postClone.find('.blog-post-top').prepend(blogPostImage)

      # Add title.
      postClone.find('.blog-post-title').html(post.title_plain)

      # Reduce length of post content if title is long.
      contentLength = if (post.title_plain.length > 30) then (220 - Math.round((post.title_plain.length - 30) * 1.2)) else 210
      postClone.find('.blog-post-content').html(stripHTML(post.content).substring(0, contentLength) + "...")

      # Add link to original post.
      postClone.find('.blog-post-link').attr('href', post.url)

      # Unhide the post, and append it to list of posts.
      postClone.removeClass('hide')
      postClone.appendTo(blogPostsContainer)
  , "jsonp").fail(->
    # Show the failed text.
    $("#blog-posts-loading-failed").removeClass('hide')
  ).always(->
    # Hide the loading text.
    $("#blog-posts-loading").addClass('hide')
  )

$(loadBlogPosts)
