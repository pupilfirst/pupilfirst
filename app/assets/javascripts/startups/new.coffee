$(document).on 'page:change', ->
  $('#team-leader-consent').click((event) ->
    teamLeaderConsentButton = $('#team-leader-consent-button')

    if $(event.target).is(':checked')
      teamLeaderConsentButton.removeClass 'disabled'
    else
      teamLeaderConsentButton.addClass 'disabled'
  )
  
  $('#startup_team_size').prop('selectedIndex',0);
  $('.startup_cofounder_3_email').hide()
  $('.startup_cofounder_4_email').hide()

  $('#startup_team_size').change ->
    if $(this).val() == '4'
      $('.startup_cofounder_3_email').show()
      $('.startup_cofounder_4_email').hide()
    else if $(this).val() == '5'
      $('.startup_cofounder_3_email').show()
      $('.startup_cofounder_4_email').show()
    else
      $('.startup_cofounder_3_email').hide()
      $('.startup_cofounder_4_email').hide()
    return
