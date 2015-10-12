$(document).on('ready page:load', ->
  $('#team-leader-consent').click((event) ->
    teamLeaderConsentButton = $('#team-leader-consent-button')

    if $(event.target).is(':checked')
      teamLeaderConsentButton.removeClass 'disabled'
    else
      teamLeaderConsentButton.addClass 'disabled'
  )
)
