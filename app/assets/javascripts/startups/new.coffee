$(document).on 'page:change', ->
  $('#team-leader-consent').click((event) ->
    teamLeaderConsentButton = $('#team-leader-consent-button')

    if $(event.target).is(':checked')
      teamLeaderConsentButton.removeClass 'disabled'
    else
      teamLeaderConsentButton.addClass 'disabled'
  )
