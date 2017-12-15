resetTimelineBuilderAndShow = ->
  timelineBuilderContainer = $('[data-react-class="TimelineBuilder"]')

  # Unmount the original timeline builder component.
  ReactDOM.unmountComponentAtNode(timelineBuilderContainer[0]);

  # Now rebuild the React component.
  ReactRailsUJS.mountComponents()

  # ...and show the modal.
  $('.timeline-builder').modal(backdrop: 'static')

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
        element: $('.founder-dashboard-togglebar__toggle-btn')[2],
        intro: startupShowTour.data('sessions')
      },
      {
        element: $('.founder-dashboard-target-group__box')[0],
        intro: startupShowTour.data('targetGroup')
      },
      {
        element: $('.founder-dashboard-target-header__container')[0],
        intro: startupShowTour.data('target')

      },
      {
        element: $('.founder-dashboard-target-status-badge__container')[0],
        intro: startupShowTour.data('targetStatus')
      },
      {
        intro: startupShowTour.data('finalMessage')
      }
    ]
  )

  tour.start()

setIntercomVisibility = ->
  _.extend(window.intercomSettings, hide_default_launcher: launcherVisible())

launcherVisible = ->
  window.innerWidth < 576

$(document).on 'turbolinks:load', ->
  if $('#founder-dashboard').length
    giveATour()
    takeTourOnClick()
    setIntercomVisibility()
