# //= require bootstrap-tabcollapse

$(document).on 'page:change', ->
  $('#activityTab').tabCollapse
    tabsClass: 'hidden-sm hidden-xs',
    accordionClass: 'visible-sm visible-xs'

  $('#complete-profile-tooltip').tooltip

$(document).on 'mouseenter', '.course-tooltip', ->
  $this = $(this)

  if @offsetWidth < @scrollWidth and !$this.attr('title')
    $this.tooltip
      title: $this.text()
      placement: 'bottom'
    $this.tooltip 'show'
