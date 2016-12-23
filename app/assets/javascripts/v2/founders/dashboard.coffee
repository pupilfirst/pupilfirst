targetAccordion = ->
  $('.target-accordion .target-title-link').click (t) ->
    dropDown = $(this).closest('.target').find('.target-description')
    $(this).closest('.target-accordion').find('.target-description').not(dropDown).slideUp(200)
    $('.target').removeClass 'open'
    if $(this).hasClass('active')
      $(this).removeClass 'active'
    else
      $(this).closest('.target-accordion').find('.target-title-link.active').removeClass 'active'
      $(this).addClass 'active'
      $(this).parent().addClass 'open'
    dropDown.stop(false, true).slideToggle(200)
    t.preventDefault()

timelineBuilderModal = ->
  $('.btn-timeline-builder').click () ->
    $('.timeline-builder').modal(backdrop: 'static')

performanceMeterModal = ->
  $('.performance-overview-link').click () ->
    $('.performance-overview').modal()

setPerformancePointer = ->
  value = $('.performance-pointer').data('value') - 5
  $('.performance-pointer')[0].style.left = value + '%'
  color = switch
    when value == 5 then 'red'
    when value == 25 then 'orange'
    when value == 45 then 'goldenrod'
    when value == 65 then 'yellowgreen'
    else 'green'
  $('.performance-pointer')[0].style.color = color

viewSlidesModal = ->
  $('.view-slides-btn').click () ->
    $('#slides-wrapper').html($(this).data('embed-code'))
    $('.view-slides').modal()

giveATour = ->
  startTour() if $('#dashboard-show-tour').data('tour-flag')

startTour = ->
  startupShowTour = $('#dashboard-show-tour')

  tour = introJs()

  tour.setOptions(
    skipLabel: 'Close',
    steps: [
      {
        element: $('.startup-profile')[0],
        intro: startupShowTour.data('intro')
      },
      {
        element: $('.program-week-number')[0],
        intro: startupShowTour.data('programWeekNumber')
      },
      {
        element: $('.target-group-header')[0],
        intro: startupShowTour.data('targetGroup')
      },
      {
        element: $('.target-title-link')[0],
        intro: startupShowTour.data('target')

      },
      {
        element: $('.target-description')[0],
        intro: startupShowTour.data('targetDetails')
      },
      {
        element: $('.target-status')[0],
        intro: startupShowTour.data('targetStatus')
      },
      {
        element: $('#add-event-button')[0],
        intro: startupShowTour.data('addEvent')
      },
      {
        element: $('#performance-button')[0],
        intro: startupShowTour.data('performance')
      }
    ]
  )

  # Open the first target so that its contents are available for intro-ing.
  $('.target-title-link:first').trigger('click')

  tour.start()

$(document).on 'turbolinks:load', ->
  if $('#founder-dashboard').length
    targetAccordion()
    timelineBuilderModal()
    giveATour()
    performanceMeterModal()
    setPerformancePointer()
    viewSlidesModal()
