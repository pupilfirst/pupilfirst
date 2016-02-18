betterFormControls = ->
  $('#timeline_event_startup_id').select2(width: '400px')
  $('#timeline_event_timeline_event_type_id').select2()

loadFoundersForStartup = ->
  $('#timeline_event_startup_id').change (e) ->
    selectedStartupId = $(e.target).find(':selected').val()
    foundersForStartupUrl = $('#timeline-event-founders-for-startup-url').data('url')

    $.get(foundersForStartupUrl, { startup_id: selectedStartupId }).success (data) ->
      $('#timeline_event_founder_id').html(data.founder_options)

$(document).on 'page:change', betterFormControls
$(document).on 'page:change', loadFoundersForStartup
