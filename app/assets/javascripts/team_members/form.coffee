setupSelect2 = ->
  $('#team_member_roles').select2()

$(document).on 'turbolinks:load', ->
  if $('.form-group.team_member_roles').length > 0
    setupSelect2()
