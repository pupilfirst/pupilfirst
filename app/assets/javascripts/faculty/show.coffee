$(document).on 'page:change', ->
  scrollcontainer = document.querySelector('.connect-session-box')
  Ps.initialize scrollcontainer

  scrollcontainermodal = document.querySelector('.faculty-pastconnect-modal')
  Ps.initialize scrollcontainermodal
