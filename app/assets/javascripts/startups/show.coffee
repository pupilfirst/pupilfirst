#= require shorten/jquery.shorten
#= require bootstrap-datepicker

exports = this

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

$(->
  $('#timeline_event_event_type').select2(
    placeholder: "Type of Event"
  )

  exports.timelineBuilderDatepicker = null

  $('#timeline-builder-date-button a').click(->
    timelineBuilderDateButton = $('#timeline-builder-date-button')

    if exports.timelineBuilderDatepicker
      exports.timelineBuilderDatepicker.toggle()
    else
      datepickerContainer = timelineBuilderDateButton.find('.datepicker-container')
      datepickerContainer.css('display', 'block')
      exports.timelineBuilderDatepicker = datepickerContainer.datepicker()
      exports.timelineBuilderDatepicker.on('changeDate', setNewEventDate)
  )

  $(document).on('click', (event) ->
    eventTarget = $(event.target)

    if exports.timelineBuilderDatepicker
      unless eventTarget.hasClass('month') or eventTarget.hasClass('day') or eventTarget.hasClass('year')
        unless $(event.target).closest('#timeline-builder-date-button').length
          exports.timelineBuilderDatepicker.toggle(false)
  )
)

$(->
  $('#upload-image').click(->
    $('#timeline_event_image').click()
  )

  $('#timeline_event_image').change(->
    $('#append-file-name')[0].innerHTML = 'attachment: ' +$(this).val().replace(/^.*[\\\/]/, '')
  )

  $('#close-link-modal-button').click(->
    $('#timeline_event_link_title')[0].value = ""
    $('#timeline_event_link_url')[0].value = ""
  )
)
