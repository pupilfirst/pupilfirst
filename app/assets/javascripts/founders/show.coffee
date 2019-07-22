# //= require bootstrap-tabcollapse

$(document).on 'turbolinks:load', ->

setupCompleteProfileTooltip = ->
  $('#complete-profile-tooltip').tooltip()

setupCourseTooltip = ->
  $('.course-tooltip').tooltip
    placement: 'bottom'
    trigger: 'hover'


registerTooltips = ->
  $('[data-toggle="tooltip"]').tooltip()

moveToFocusedEvent = ->
  if $("#focused-event").length
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
      # Enable the button again.
      loadLink.text('Load more events')
      loadLink.removeClass('disabled')
    )
  )

# The bind / unbind approach is required since content is loaded dynamically on page, and listeners need to be set up
# for such content since they appear after page load.
unbindListeners = ->
  $('.js-startup-show__load-events-link').off('click')

bindListeners = ->
  registerTooltips()
  handleLoadMoreEvents()

$(document).on 'turbolinks:load', ->
  if $('#founder__show')
    bindListeners()
    moveToFocusedEvent()
    setupCompleteProfileTooltip()
    setupCourseTooltip()
