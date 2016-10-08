SidebarMenuToggle = ->
  bodyEl = document.body
  content = document.querySelector('.content-wrap')
  openbtn = document.getElementById('open-button')
  closebtn = document.getElementById('close-button')
  isOpen = false

  init = ->
    initEvents()

  initEvents = ->
    if $('#sixways-container').length
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
      $('.module-fixed-head').removeClass 'hide-head'
      $('.sixways-right').removeClass 'margin-top-adjust'
    else
      bodyEl.classList.add 'show-menu'
      $('#hambuger-icon').addClass 'open'
      $('.module-fixed-head').addClass 'hide-head'
      $('.sixways-right').addClass 'margin-top-adjust'
    isOpen = !isOpen

  init()

JqueryAccordion = ->
  $.sidebarMenu $('.sidebar-menu')

SimpleScrollBar = ->
  myScrollbar = new GeminiScrollbar(element: document.querySelector('#module-links')).create()

ModuleTooltip = ->
  $('.module-title').tooltip()

helpIconTooltip = ->
  $('.guest-banner .help-icon').tooltip()


$(document).on 'turbolinks:load', ->
  if $('#module-links').length
    SidebarMenuToggle()

$(document).on 'turbolinks:load', ->
  if $('#sidebar-menu-container').length
    JqueryAccordion()

$(document).on 'turbolinks:load', ->
  if $('#sixways-container').length
    SimpleScrollBar()
    ModuleTooltip()
    helpIconTooltip()