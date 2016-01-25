$(document).on 'page:change', ->
  $('#karma_point_startup_id').select2(width: '400px')

loadFoundersForStartup = ->
  $('#karma_point_startup_id').change (e) ->
    selectedStartupId = $(e.target).find(':selected').val()
    foundersForStartupUrl = $('#karma-point-founders-for-startup-url').data('url')

    $.get(foundersForStartupUrl, { startup_id: selectedStartupId }).success (data) ->
      $('#karma_point_user_id').html(data.founder_options)

$(document).on 'page:change', loadFoundersForStartup
