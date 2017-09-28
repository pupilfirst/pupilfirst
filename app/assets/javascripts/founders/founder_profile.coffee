# //= require bootstrap-tabcollapse

$(document).on 'turbolinks:load', ->

setupCalendarTabCollapse = ->
  $('#activityTab').tabCollapse
    tabsClass: 'd-lg-block',
    accordionClass: 'd-lg-none'

setupCompleteProfileTooltip = ->
  $('#complete-profile-tooltip').tooltip()

setupCourseTooltip = ->
  $('.course-tooltip').tooltip
    placement: 'bottom'
    trigger: 'hover'

$(document).on 'turbolinks:load', ->
  if $('#founder__founder-profile')
    setupCalendarTabCollapse()
    setupCompleteProfileTooltip()
    setupCourseTooltip()
