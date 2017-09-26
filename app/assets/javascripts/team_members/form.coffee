setupSelect2 = ->
  $('#team_member_roles').select2()

$(document).on 'turbolinks:load', ->
  if $('#team_member_roles').length > 0
    setupSelect2()
