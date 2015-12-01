$(document).on 'page:change', ->
  $('#assign-karma-points #date').datepicker(dateFormat: 'yy-mm-dd')

handleKarmaPointCreation = ->
  $('form.add_karma_points_for_message').on "ajax:success", (e, data, status, xhr) ->
    if data.error
      console.log(data)
      alert(data.error)
    else
      $("td#message-actions-#{data.public_slack_message_id}").html("<a href='#{data.url}'>##{data.id} &mdash; #{data.points} points &mdash; #{data.activity_type}.</a>")

$(document).on 'page:change', handleKarmaPointCreation
