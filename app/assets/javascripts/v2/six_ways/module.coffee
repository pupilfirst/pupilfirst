SidebarMenuEffects = ->
  bodyEl = document.body
  content = document.querySelector('.content-wrap')
  openbtn = document.getElementById('open-button')
  closebtn = document.getElementById('close-button')
  isOpen = false

  init = ->
    initEvents()

  initEvents = ->
    openbtn.addEventListener 'click', toggleMenu

    if closebtn
      closebtn.addEventListener 'click', toggleMenu
    # close the menu element if the target it´s not the menu element or one of its descendants..
    content.addEventListener 'click', (ev) ->
      target = ev.target
      if isOpen and target != openbtn
        toggleMenu()

  toggleMenu = ->
    if isOpen
      bodyEl.classList.remove 'show-menu'
      $('#hambuger-icon').removeClass 'open'
    else
      bodyEl.classList.add 'show-menu'
      $('#hambuger-icon').addClass 'open'
    isOpen = !isOpen

  init()

JqueryAccordion = ->
  $.sidebarMenu $('.sidebar-menu')


$(document).on 'page:change', SidebarMenuEffects
$(document).on 'page:change', JqueryAccordion
