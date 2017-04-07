perfectScrollbar = ->
  # $('.connect-session-box').perfectScrollbar()
  # $('.faculty-pastconnect-modal').perfectScrollbar()
  #
  # if $('#faculty-show-xs-test').is(':visible')
  #   $('.connect-session-box').perfectScrollbar('destroy')

  # myScrollbar = new GeminiScrollbar(element: document.querySelector('.connect-session-box')).create()
  # $('.faculty-pastconnect-modal').on 'shown.bs.modal', ->

$(document).on 'turbolinks:load', ->
  perfectScrollbar()
