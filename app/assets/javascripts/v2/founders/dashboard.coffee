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
    $('#timeline-builder').modal backdrop: 'static'

performanceMeterModal = ->
  $('.performance-overview-link').click () ->
    $('.performance-overview').modal()

customFileupload = ->
  inputs = document.querySelectorAll('.file-choose')
  Array::forEach.call inputs, (input) ->
    label = input.nextElementSibling
    labelVal = label.innerHTML
    input.addEventListener 'change', (e) ->
      fileName = ''
      if @files and @files.length > 1
        fileName = (@getAttribute('data-multiple-caption') or '').replace('{count}', @files.length)
      else
        fileName = e.target.value.split('\\').pop()
      if fileName
        label.querySelector('span').innerHTML = fileName
      else
        label.innerHTML = labelVal

$(document).on 'turbolinks:load', ->
  if $('#founder-dashboard').length
    targetAccordion()
    timelineBuilderModal()
    customFileupload()
    performanceMeterModal()
