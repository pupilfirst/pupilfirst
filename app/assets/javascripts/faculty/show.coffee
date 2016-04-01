$(document).on 'page:change', ->
  $('.connect-session-box').perfectScrollbar()
  $('.faculty-pastconnect-modal').perfectScrollbar()

  if $('#faculty-show-xs-test').is(':visible')
    $('.connect-session-box').perfectScrollbar('destroy')
