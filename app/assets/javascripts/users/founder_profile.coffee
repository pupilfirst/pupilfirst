# //= require bootstrap-tabcollapse

$(document).on 'page:change', ->
  $('#activityTab').tabCollapse
    tabsClass: 'hidden-sm hidden-xs',
    accordionClass: 'visible-sm visible-xs'
