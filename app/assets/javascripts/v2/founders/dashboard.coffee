targetAccordion = ->
  scope = $('.target-accordion .founder-dashboard-target-header__container')
  scope.off('click')

  scope.on('click', (t) ->
    dropDown = $(this).closest('.target').find('.target-description')
    $(this).closest('.target-accordion').find('.target-description').not(dropDown).slideUp(200)
    $('.target').removeClass 'open'
    if $(this).hasClass('active')
      $(this).removeClass 'active'
    else
      $(this).closest('.target-accordion').find('.founder-dashboard-target-header__container.active').removeClass 'active'
      $(this).addClass 'active'
      $(this).parent().addClass 'open'
    dropDown.stop(false, true).slideToggle(200)
    t.preventDefault()
  )

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
    $('.js-timeline-builder__timeline-event-type-select-wrapper').popover('dispose');
    $('.js-timeline-builder__submit-button').popover('dispose');
    $('.image-upload').popover('dispose');
    $('.timeline-builder__social-bar-toggle-switch').popover('dispose');
  )

handleTimelineBuilderModal = ->
  scope = $('.js-founder-dashboard__trigger-builder')
  scope.off('click')

  scope.on('click', (event) ->
    submitButton = $(event.target)

    selectedTimelineEventTypeId = submitButton.data('timelineEventTypeId')
    selectedTargetId = submitButton.data('targetId')

    timelineBuilderContainer = $('[data-react-class="TimelineBuilder"]')
    timelineBuilderHiddenForm = $('.js-timeline-builder__hidden-form')

    # Amend the props with target ID and selected timeline event type.
    reactProps = JSON.parse(timelineBuilderContainer.attr('data-react-props'))

    if selectedTargetId
      reactProps['targetId'] = selectedTargetId
    else
      delete reactProps['targetId']

    if selectedTimelineEventTypeId
      reactProps['selectedTimelineEventTypeId'] = selectedTimelineEventTypeId
    else
      delete reactProps['selectedTimelineEventTypeId']

    timelineBuilderContainer.attr('data-react-props', JSON.stringify(reactProps))

    resetTimelineBuilderAndShow()
  )

setPerformancePointer = ->
  if $('.performance-pointer').length
    value = $('.performance-pointer').data('value') - 5
    $('.performance-pointer')[0].style.left = value + '%'
    color = switch
      when value == 5 then 'red'
      when value == 25 then 'orange'
      when value == 45 then 'goldenrod'
      when value == 65 then 'yellowgreen'
      else 'green'
    $('.performance-pointer')[0].style.color = color

giveATour = ->
  startTour() if $('#dashboard-show-tour').data('tour-flag')

startTour = ->
  startupShowTour = $('#dashboard-show-tour')

  tour = introJs()

  tour.setOptions(
    skipLabel: 'Close',
    steps: [
      {
        element: $('.founder-dashboard-header__container')[0],
        intro: startupShowTour.data('intro')
      },
      {
        element: $('.founder-dashboard-togglebar__toggle-group')[0],
        intro: startupShowTour.data('toggleBar')
      },
      {
        element: $('.founder-dashboard-togglebar__toggle-btn')[0],
        intro: startupShowTour.data('targets')
      },
      {
        element: $('.founder-dashboard-togglebar__toggle-btn')[1],
        intro: startupShowTour.data('chores')
      },
      {
        element: $('.founder-dashboard-togglebar__toggle-btn')[2],
        intro: startupShowTour.data('sessions')
      },
      {
        element: $('.founder-dashboard-target-group__header')[0],
        intro: startupShowTour.data('targetGroup')
      },
      {
        element: $('.founder-dashboard-target-header__container')[0],
        intro: startupShowTour.data('target')

      },
      {
        element: $('.target-description')[0],
        intro: startupShowTour.data('targetDetails')
      },
      {
        element: $('.founder-dashboard-target-header__status-badge')[0],
        intro: startupShowTour.data('targetStatus')
      }
    ]
  )

  # Open the first target so that its contents are available for intro-ing.
  $('.founder-dashboard-target-header__container:first').trigger('click')

  tour.start()

hideIntercomOnSmallScreen = ->
    # TODO: There might be a better way to do this!
    window.Intercom('shutdown') if window.innerWidth < 576

loadProgramWeekOnDemand = ->
  loadingElement = $('.js-program-week__loading')
  return unless loadingElement.length

  new Waypoint.Inview({
    element: loadingElement[0]
    enter: (direction) ->
      return if loadingElement.data('loading')
      loadingElement.data('loading', true)
      weekUrl = loadingElement.data('weekUrl')
      thisWaypoint = this

      $.get(weekUrl).done((data) ->
        programWeek = loadingElement.closest('.program-week')
        programWeek.replaceWith(data)

        # Set up loading waypoint for the next week.
        loadProgramWeekOnDemand()

        # Set up click listeners on the new program week.
        handleTimelineBuilderModal()
        targetAccordion()
        viewSlidesModal()
      ).fail(->
        console.log("Failed to load week's data from server. :-(")
      ).always(->
        # Delete this waypoint.
        thisWaypoint.destroy()
      )
  })

$(document).on 'turbolinks:load', ->
  if $('#founder-dashboard').length
#    targetAccordion()
#    handleTimelineBuilderModal()
#    handleTimelineBuilderPopoversHiding()
    giveATour()
    hideIntercomOnSmallScreen()
    setPerformancePointer()
#    loadProgramWeekOnDemand()
