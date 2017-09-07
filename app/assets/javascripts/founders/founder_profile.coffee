# //= require bootstrap-tabcollapse

$(document).on 'turbolinks:load', ->
  $('#activityTab').tabCollapse
    tabsClass: 'd-lg-block',
    accordionClass: 'd-lg-none'

  $('#complete-profile-tooltip').tooltip

$(document).on 'mouseenter', '.course-tooltip', ->
  $this = $(this)

  if @offsetWidth < @scrollWidth and !$this.attr('title')
    $this.tooltip
      title: $this.text()
      placement: 'bottom'
    $this.tooltip 'show'
