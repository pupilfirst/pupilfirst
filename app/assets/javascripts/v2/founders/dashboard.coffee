targetAccordion = ->
  scope = $('.target-accordion .target-title-link')
  scope.off('click')

  scope.on('click', (t) ->
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
  scope = $('.view-slides-btn')
  scope.off('click')

  scope.on('click', (event) ->
    slidesModal = $('.view-slides')
    viewSlidesButton = $(event.target).closest('button')

    slidesModal.on 'show.bs.modal', ->
      $('#slides-wrapper').html(viewSlidesButton.data('embed-code'))

    slidesModal.on 'hide.bs.modal', ->
      $('#slides-wrapper').html('')

    slidesModal.modal()
  )

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

hideIntercomOnSmallScreen = ->
    # TODO: There might be a better way to do this!
    window.Intercom('shutdown') if window.innerWidth < 576

loadPerformanceOnDemand = ->
  $('#performance-button').click (event) ->
    performanceOverview = $('.performance-overview')

    # Open the modal.
    performanceOverview.modal()

    # Load performance data using AJAX if required.
    unless performanceOverview.data('loaded') || performanceOverview.data('loading')
      performanceOverview.data('loading', true)
      performanceUrl = $(event.target).closest('button').data('performanceUrl')

      $.get(performanceUrl).done((data) ->
        performanceOverview.find('.modal-body').html(data)
        setPerformancePointer()
        performanceOverview.data('loaded', true)
      ).fail(->
        console.log("Failed to load performance data from server. :-(")
      ).always(->
        performanceOverview.data('loading', false)
      )

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
    targetAccordion()
    handleTimelineBuilderModal()
    handleTimelineBuilderPopoversHiding()
    giveATour()
    viewSlidesModal()
    hideIntercomOnSmallScreen()
    loadPerformanceOnDemand()
    loadProgramWeekOnDemand()
