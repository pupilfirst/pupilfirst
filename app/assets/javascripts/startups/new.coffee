$(document).on 'page:change', ->
  $('#team-leader-consent').click((event) ->
    teamLeaderConsentButton = $('#team-leader-consent-button')

    if $(event.target).is(':checked')
      teamLeaderConsentButton.removeClass 'disabled'
    else
      teamLeaderConsentButton.addClass 'disabled'
  )

  updateVisibleFields()

  $('#startup_team_size').change ->
    updateVisibleFields()

updateVisibleFields = ->
    if $('#startup_team_size').val() == '4'
      $('.startup_cofounder_3_email').show()
      $('.startup_cofounder_4_email').hide()
    else if $('#startup_team_size').val() == '5'
      $('.startup_cofounder_3_email').show()
      $('.startup_cofounder_4_email').show()
    else if $('#startup_team_size').val() == '3'
      $('.startup_cofounder_3_email').hide()
      $('.startup_cofounder_4_email').hide()
    return
