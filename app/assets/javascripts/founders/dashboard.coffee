resetTimelineBuilderAndShow = ->
  timelineBuilderContainer = $('[data-react-class="TimelineBuilder"]')

  # Unmount the original timeline builder component.
  ReactDOM.unmountComponentAtNode(timelineBuilderContainer[0]);

  # Now rebuild the React component.
  ReactRailsUJS.mountComponents()

  # ...and show the modal.
  $('.timeline-builder').modal(backdrop: 'static')

setIntercomVisibility = ->
  _.extend(window.intercomSettings, hide_default_launcher: launcherVisible())

launcherVisible = ->
  window.innerWidth < 576

$(document).on 'turbolinks:load', ->
  if $('#founder-dashboard').length
    setIntercomVisibility()
