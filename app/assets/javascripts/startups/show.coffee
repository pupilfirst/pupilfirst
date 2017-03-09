registerTooltips = ->
  $('[data-toggle="tooltip"]').tooltip()

handleShowFeedbackClick = ->
  $('.show-feedback-button').on('click', (event) ->
    feedback = $(event.target).data('feedback')
    faculty = $(event.target).data('faculty')
    attachmentName = $(event.target).data('attachment-name')
    attachmentUrl = $(event.target).data('attachment-url')
    openFeedbackModel(feedback, faculty, attachmentName, attachmentUrl)
  )

openFeedbackModel = (feedback, faculty, attachmentName, attachmentUrl) ->
  $('#improvement-modal').find('.feedback-text').html("<pre>#{feedback}</pre>")
  $('#improvement-modal').find('.modal-title').html("Feedback from #{faculty}")
  if attachmentUrl
    $('#improvement-modal').find('.attachment').removeClass('hidden')
    $('#improvement-modal').find('.attachment-name').html(" #{attachmentName}")
    $('#improvement-modal').find('.attachment-download-btn').attr('href', "#{attachmentUrl}")
  $('#improvement-modal').modal('show')

showDefaultFeedback = ->
  if $('#improvement-modal') and $('#improvement-modal').data('feedback') and $('#improvement-modal').data('faculty')
    feedback = $('#improvement-modal').data('feedback')
    faculty = $('#improvement-modal').data('faculty')
    attachmentName = $('#improvement-modal').data('attachment-name')
    attachmentUrl = $('#improvement-modal').data('attachment-url')
    openFeedbackModel(feedback, faculty, attachmentName, attachmentUrl)

resetOnHideFeedbackModal = ->
  $('#improvement-modal').on 'hidden.bs.modal', (event) ->
    $('#improvement-modal').find('.feedback-text').html("")
    $('#improvement-modal').find('.modal-title').html("")
    $('#improvement-modal').find('.attachment').addClass("hidden")
    $('#improvement-modal').find('.attachment-name').html("")
    $('#improvement-modal').find('.attachment-download-btn').attr('href', "")

moveToFocusedEvent = ->
  if $(".startup-show__og-timeline-event").length
    window.location.hash = "#focused-event"

handleLoadMoreEvents = ->
  $('.js-startup-show__load-events-link').on('click', (event) ->
    event.preventDefault()
    loadLink = $(event.target)

    # Disable the button.
    loadLink.addClass('disabled')
    loadLink.text('Loading...')

    # Load new events.
    loadUrl = loadLink.data('loadUrl')

    $.get(
      loadUrl
    ).done((data) ->
      # Remove listeners.
      unbindListeners()

      # Delete the container of old button.
      loadLink.closest('.text-center').remove()

      # Add new content.
      $('#timeline-list').append(data);

      # Reset listeners.
      bindListeners()
    ).fail((data) ->
      # Display an alert message.
      new PNotify(
        type: 'error',
        title: 'Failed to load events!',
        text: 'Something went wrong when we tried to load more events. The SV.CO team has been notified of this error.'
      )

      # Enable the button again.
      loadLink.text('Load more events')
      loadLink.removeClass('disabled')
    )
  )

# The bind / unbind approach is required since content is loaded dynamically on page, and listeners need to be set up
# for such content since they appear after page load.
unbindListeners = ->
  $('.show-feedback-button').off('click')
  $('.js-startup-show__load-events-link').off('click')

bindListeners = ->
  registerTooltips()
  handleShowFeedbackClick()
  handleLoadMoreEvents()

$(document).on 'turbolinks:load', ->
  if $('#startups__show').length
    bindListeners()
    showDefaultFeedback()
    resetOnHideFeedbackModal()
    moveToFocusedEvent()
