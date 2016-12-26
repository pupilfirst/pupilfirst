targetAccordion = ->
  $('.target-accordion .target-title-link').click (t) ->
    dropDown = $(this).closest('.target').find('.target-description')
    $(this).closest('.target-accordion').find('.target-description').not(dropDown).slideUp(200)
    $('.target').removeClass 'open'
    if $(this).hasClass('active')
      $(this).removeClass 'active'
    else
      $(this).closest('.target-accordion').find('.target-title-link.active').removeClass 'active'
      $(this).addClass 'active'
      $(this).parent().addClass 'open'
    dropDown.stop(false, true).slideToggle(200)
    t.preventDefault()

resetTimelineBuilderAndShow = ->
  timelineBuilderContainer = $('[data-react-class="TimelineBuilder"]')

  # Unmount the original timeline builder component.
  ReactDOM.unmountComponentAtNode(timelineBuilderContainer[0]);

  # Now rebuild the React component.
  ReactRailsUJS.mountComponents()

  # ...and show the modal.
  $('.timeline-builder').modal(backdrop: 'static')

handleTimelineBuilderPopoversHiding = ->
  # Hide all error popovers if modal is closed
  $('.timeline-builder').on('hide.bs.modal', (event) ->
    $('.js-timeline-builder__textarea').popover('dispose');
    $('.date-of-event').popover('dispose');
    $('.timeline-builder__timeline_event_type').popover('dispose');
    $('.js-timeline-builder__submit-button').popover('dispose');
    $('.image-upload').popover('dispose');
  )

handleTimelineBuilderModal = ->
  $('.js-founder-dashboard__add-event-button').click(resetTimelineBuilderAndShow)

handleTimelineBuilderModalPrefilled = ->
  $('.js-founder-dashboard__target-submit-button').click (event) ->
    submitButton = $(event.target)
    selectedTimelineEventTypeId = submitButton.data('timelineEventTypeId')
    selectedTargetId = submitButton.data('targetId')

    timelineBuilderContainer = $('[data-react-class="TimelineBuilder"]')
    timelineBuilderHiddenForm = $('.js-timeline-builder__hidden-form')

    # Amend the props with target ID and selected timeline event type.
    reactProps = JSON.parse(timelineBuilderContainer.attr('data-react-props'))

    reactProps['targetId'] = selectedTargetId

    if selectedTimelineEventTypeId
      reactProps['selectedTimelineEventTypeId'] = selectedTimelineEventTypeId
    else
      delete reactProps['selectedTimelineEventTypeId']

    timelineBuilderContainer.attr('data-react-props', JSON.stringify(reactProps))

    resetTimelineBuilderAndShow()

performanceMeterModal = ->
  $('.performance-overview-link').click () ->
    $('.performance-overview').modal()

setPerformancePointer = ->
  value = $('.performance-pointer').data('value') - 5
  $('.performance-pointer')[0].style.left = value + '%'
  color = switch
    when value == 5 then 'red'
    when value == 25 then 'orange'
    when value == 45 then 'goldenrod'
    when value == 65 then 'yellowgreen'
    else 'green'
  $('.performance-pointer')[0].style.color = color

viewSlidesModal = ->
  $('.view-slides-btn').click () ->
    $('#slides-wrapper').html($(this).data('embed-code'))
    $('.view-slides').modal()

giveATour = ->
  startTour() if $('#dashboard-show-tour').data('tour-flag')

startTour = ->
  startupShowTour = $('#dashboard-show-tour')

  tour = introJs()

  tour.setOptions(
    skipLabel: 'Close',
    steps: [
      {
        element: $('.startup-profile')[0],
        intro: startupShowTour.data('intro')
      },
      {
        element: $('.program-week-number')[0],
        intro: startupShowTour.data('programWeekNumber')
      },
      {
        element: $('.target-group-header')[0],
        intro: startupShowTour.data('targetGroup')
      },
      {
        element: $('.target-title-link')[0],
        intro: startupShowTour.data('target')

      },
      {
        element: $('.target-description')[0],
        intro: startupShowTour.data('targetDetails')
      },
      {
        element: $('.target-status')[0],
        intro: startupShowTour.data('targetStatus')
      },
      {
        element: $('#add-event-button')[0],
        intro: startupShowTour.data('addEvent')
      },
      {
        element: $('#performance-button')[0],
        intro: startupShowTour.data('performance')
      }
    ]
  )

  # Open the first target so that its contents are available for intro-ing.
  $('.target-title-link:first').trigger('click')

  tour.start()

$(document).on 'turbolinks:load', ->
  if $('#founder-dashboard').length
    targetAccordion()
    handleTimelineBuilderModal()
    handleTimelineBuilderModalPrefilled()
    handleTimelineBuilderPopoversHiding()
    giveATour()
    performanceMeterModal()
    setPerformancePointer()
    viewSlidesModal()
