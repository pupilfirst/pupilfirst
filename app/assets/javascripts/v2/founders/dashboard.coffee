resetTimelineBuilderAndShow = ->
  timelineBuilderContainer = $('[data-react-class="TimelineBuilder"]')

  # Unmount the original timeline builder component.
  ReactDOM.unmountComponentAtNode(timelineBuilderContainer[0]);

  # Now rebuild the React component.
  ReactRailsUJS.mountComponents()

  # ...and show the modal.
  $('.timeline-builder').modal(backdrop: 'static')

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

takeTourOnClick = ->
  $('#filter-targets-dropdown__tour-button').on('click', startTour)

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

$(document).on 'turbolinks:load', ->
  if $('#founder-dashboard').length
    giveATour()
    hideIntercomOnSmallScreen()
    setPerformancePointer()
    takeTourOnClick()
