setButtonState = (button, state) ->
  if state == 'preparing'
    button.find('.download').addClass('hide')
    button.find('.preparing-download').removeClass('hide')
    button.prop('disabled', true)
  else if state == 'started'
    button.removeClass('btn-primary').addClass('btn-success')
    button.find('.preparing-download').addClass('hide')
    button.find('.download-started').removeClass('hide')
  else if state == 'failed'
    button.removeClass('btn-primary').addClass('btn-danger')
    button.find('.preparing-download').addClass('hide')
    button.find('.download-failed').removeClass('hide')

resourceDownloadManager = ->
  $('.download-resource').on('click', (event) ->
    # Switch to loading state.
    downloadButton = $(event.target).closest('.download-resource')

    # Hide play button, if it exists.
    downloadButton.siblings('.stream-resource').hide()

    setButtonState(downloadButton, 'preparing')

    # Retrieve actual download URL.
    generatorUrl = downloadButton.data('generatorUrl')

    $.get(generatorUrl, (data) ->
      setButtonState(downloadButton, 'started')
      window.open data.resource_download_url, "_blank"
    ).fail(->
      setButtonState(downloadButton, 'failed')
    )
  )

$(document).on 'page:change', resourceDownloadManager
