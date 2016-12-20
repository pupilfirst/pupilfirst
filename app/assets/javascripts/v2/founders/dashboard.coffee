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

customFileupload = ->
  inputElement = $('.js-attachment-file')

  inputElement.on 'change', (event) ->
    labelElement = inputElement.next('.js-attachment-file-label')
    fileName = $(event.target).val().split('\\').pop()
    labelText = fileName ? fileName : ''
    labelElement.find('span').html(labelText)

giveATour = ->
  startTour() if $('#dashboard-show-tour').length > 0

startTour = ->
  startupShowTour = $('#dashboard-show-tour')

  tour = introJs()

  tour.setOptions(
    skipLabel: 'Close',
    steps: [
      {
        element: $('.dashboard-header')[0],
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
        element: $('.dashboard-header-container')[0],
        intro: startupShowTour.data('addEvent')
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
    customFileupload()
    giveATour()
    performanceMeterModal()
