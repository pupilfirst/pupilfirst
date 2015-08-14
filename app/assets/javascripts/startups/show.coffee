#= require shorten/jquery.shorten
#= require bootstrap-datepicker

exports = {
  timelineBuilderDatepicker: null
  addButtonClicked: null
}

shortenText = ->
  $('.about-startup').shorten(
    showChars: 200
  )

$(shortenText)

$(->
  $('a#verified-icon').tooltip()
)

$(->
  $(".tl_link_button").click((e) ->
    if ($(this).find(".ink").length == 0)
      $(this).prepend("<span class='ink'></span>")

    ink = $(this).find(".ink")
    ink.removeClass("animate")

    if (!ink.height() && !ink.width())
      d = Math.max($(this).outerWidth(), $(this).outerHeight())
      ink.css({height: d, width: d})

    x = e.pageX - $(this).offset().left - ink.width() / 2
    y = e.pageY - $(this).offset().top - ink.height() / 2

    ink.css({top: y + 'px', left: x + 'px'}).addClass("animate")
  )
)

$(->
  $('#read-from-beginning').click(->
    $('html, body').animate({scrollTop: $(document).height()}, 'slow')
    return false
  )

  if ($(window).width() < 767)
    $("#verified").removeClass("tooltip-right")
    $("#verified").removeAttr("data-tooltip")

  $(window).resize(->
    if ($(window).width() < 767)
      $("#verified").removeClass("tooltip-right")
      $("#verified").removeAttr("data-tooltip")
  )
)

$(->
  $("#new-event-form .panel-heading").click(->
    $("#new-event-form .panel-body").collapse('toggle')
    $("#new-event-form .fa-plus").toggleClass("hidden")
    $("#new-event-form .fa-minus").toggleClass("hidden")
  )
)

setNewEventDate = (e) ->
  timelineBuilderDateButton = $('#timeline-builder-date-button')

  # Store the time in form field.
  timelineBuilderDateButton.find('input').val(e.date.toISOString())

  # Hide the datepicker.
  exports.timelineBuilderDatepicker.toggle()

  # Indicate that a date has been picked.
  timelineBuilderDateButton.find('.fa-calendar').addClass('hidden')
  timelineBuilderDateButton.find('.fa-calendar-check-o').removeClass('hidden')

timelineBuilderSubmitChecks = ->
  $('#new_timeline_event').submit( (event)->
    form = $(event.target)

    typeOfEventPresent = !!form.find('select#timeline_event_event_type').val()
    dateOfEventPresent = !!form.find('input#timeline_event_event_on').val()

    unless dateOfEventPresent
      $('#timeline-builder-date-button > a').removeClass('btn-default').addClass('btn-danger')
      timelineBuilderDateButton = $('#timeline-builder-date-button')

      timelineBuilderDateButton.tooltip(
        placement: 'top',
        title: 'When did this event occur?',
        trigger: 'manual'
      )

      timelineBuilderDateButton.tooltip('show')

    unless typeOfEventPresent
      select2Container = form.find('.select2-container')
      select2Container.addClass('has-error')

      select2Container.tooltip(
        placement: 'bottom',
        title: 'What type of event is this?',
        trigger: 'manual'
      )

      select2Container.tooltip('show')

    return false unless typeOfEventPresent && dateOfEventPresent
  )

clearErrorsOnOpeningSelect2 = ->
  $('#timeline_event_event_type').on('select2-opening', ->
    console.log 'here'

    select2Container = $('#new_timeline_event .select2-container')
    select2Container.removeClass('has-error')
    select2Container.tooltip('destroy')
  )

setupSelect2ForEventType = ->
  $('#timeline_event_event_type').select2(
    placeholder: "Type of Event"
  )

handleDateButtonClick = ->
  $('#timeline-builder-date-button a').click(->
    timelineBuilderDateButton = $('#timeline-builder-date-button')

    # Remove error class and tooltip on it if its present
    timelineBuilderDateButton.find('a').removeClass('btn-danger').addClass('btn-default')
    timelineBuilderDateButton.tooltip('destroy')

    if exports.timelineBuilderDatepicker
      exports.timelineBuilderDatepicker.toggle()
    else
      datepickerContainer = timelineBuilderDateButton.find('.datepicker-container')
      datepickerContainer.css('display', 'block')
      exports.timelineBuilderDatepicker = datepickerContainer.datepicker()
      exports.timelineBuilderDatepicker.on('changeDate', setNewEventDate)
  )

closeDatePickerOnExternalClick = ->
  $(document).on('click', (event) ->
    eventTarget = $(event.target)

    if exports.timelineBuilderDatepicker
      unless eventTarget.hasClass('month') or eventTarget.hasClass('day') or eventTarget.hasClass('year')
        unless $(event.target).closest('#timeline-builder-date-button').length
          exports.timelineBuilderDatepicker.toggle(false)
  )

$(timelineBuilderSubmitChecks)
$(setupSelect2ForEventType)
$(clearErrorsOnOpeningSelect2)
$(handleDateButtonClick)
$(closeDatePickerOnExternalClick)

$(->
  $('#upload-image').click(->
    $('#timeline_event_image').click()
  )

  $('#timeline_event_image').change(->
    $('#append-file-name').html('attachment: ' +$(this).val().replace(/^.*[\\\/]/, ''))
  )

  $('#add-link-button').click(->
    if $('#timeline_event_link_title').val() and $('#timeline_event_link_url').val()
      exports.addButtonClicked = true
      $('#add-link-modal').modal('hide')
    else
      unless $('#timeline_event_link_title').val()
        addErrorMarkers('#link-title-group')
      unless $('#timeline_event_link_url').val()
        addErrorMarkers('#link-url-group')
  )

  $('#timeline_event_link_title').focus(->
    clearErrorMarkers('#link-title-group')
  )

  $('#timeline_event_link_url').focus(->
    clearErrorMarkers('#link-url-group')
  )

  $('#add-link-modal').on('hidden.bs.modal', (e) ->
    unless exports.addButtonClicked
      $('#timeline_event_link_title').val("")
      $('#timeline_event_link_url').val("")
      exports.addButtonClicked = false
    clearErrorMarkers('#link-title-group')
    clearErrorMarkers('#link-url-group')
  )

  clearErrorMarkers = (formGroup) ->
    $(formGroup).removeClass('has-error has-feedback')
    $(formGroup).find('span').addClass('hidden')

  addErrorMarkers = (formGroup) ->
    $(formGroup).addClass('has-error has-feedback')
    $(formGroup).find('span').removeClass('hidden')
)
