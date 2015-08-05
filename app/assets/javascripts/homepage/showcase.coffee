showcaseEmbeds = ->
  # Set iframe source and modal title when video modal is shown.
  $('#showcase-video').on('show.bs.modal', (event) ->
    button = $(event.relatedTarget)
    title = button.data('title')
    video = button.data('video')
    modal = $(this)
    modal.find('.modal-title').text(title)
    modal.find('.modal-body iframe').attr('src', video)
  )

  # Removes iframe src when the video modal is hidden.
  $('#showcase-video').on('hidden.bs.modal', (event) ->
    modal = $(this)
    modal.find('.modal-body iframe').attr('src', '')
  )

  # Sets title and populates timeline modal.
  $('#showcase-timeline').on('show.bs.modal', (event) ->
    # Button that triggered the modal
    button = $(event.relatedTarget)

    title = button.data('title')
    timeline = button.data('timeline')
    modal = $(this)

    modal.find('.modal-title').text(title)

    image = document.createElement("img");
    image.src = timeline
    image.className = 'img-responsive'
    image.id = 'timeline-image'

    parent = $("#timeline-image-wrapper")
    parent.append(image)
  )

  # Removes timeline image from timeline modal.
  $('#showcase-timeline').on('hidden.bs.modal', (event) ->
    $('#timeline-image').remove()
  )

  # Make the thumbnails trigger the right modal.
  $('.showcase-activate').on('click', (event) ->
    video = $(this).parent('.thumbnail').find('.showcase-video-trigger')
    timeline = $(this).parent('.thumbnail').find('.showcase-timeline-trigger')

    if video?
      video.click()
    else
      timeline.click()

    false
  )

$(showcaseEmbeds)
