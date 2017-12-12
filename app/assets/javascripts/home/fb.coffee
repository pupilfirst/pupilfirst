hideIntercom = ->
  _.extend(window.intercomSettings, hide_default_launcher: true)

$(document).on 'turbolinks:load', ->
  if $('#home__fb').length > 0
    hideIntercom()
