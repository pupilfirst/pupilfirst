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
  timelineBuilderDateButton.find('a').addClass('green')
  timelineBuilderDateButton.find('span').html('&nbsp;' + moment(e.date).format('DD/MM/YYYY'))


timelineBuilderSubmitChecks = ->
  $('#new_timeline_event').submit( (event)->
    form = $(event.target)

    typeOfEventPresent = !!form.find('select#timeline_event_timeline_event_type_id').val()
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
  $('#timeline_event_timeline_event_type_id').on('select2-opening', ->
    select2Container = $('#new_timeline_event .select2-container')
    select2Container.removeClass('has-error')
    select2Container.tooltip('destroy')
  )

setupSelect2ForEventType = ->
  $('#timeline_event_timeline_event_type_id').select2(
    placeholder: "Type of Event"
  )

matchSampleTextToEventType = ->
  $('#timeline_event_timeline_event_type_id').on('select2-selected', (e) ->
    newPlaceHolder = $('#timeline_event_timeline_event_type_id :selected').attr("data-sample-text")
    $('#timeline_event_description').attr("placeholder",newPlaceHolder)
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

removeSelectedImage = ->
  uploadImage = $('#upload-image')
  uploadImage.removeClass('green-text')
  uploadImage.find('span').html('Upload an Image')
  $('#timeline_event_image').val('')
  $('#remove-selected-image').addClass('hidden')

handleImageUpload = ->
  $('#upload-image').click(->
    $('#timeline_event_image').click()
  )

  $('#timeline_event_image').change(->
    newValue = $(this).val()

    unless newValue
      removeSelectedImage()
      return

    uploadImage = $('#upload-image')

    # Remove path info from filename before inserting it into view.
    uploadImage.find('span').html(newValue.replace(/^.*[\\\/]/, ''))

    uploadImage.addClass('green-text')
    $('#remove-selected-image').removeClass('hidden')
  )

  $('#remove-selected-image').click(removeSelectedImage)

isUrlValid = (url) ->
  /^(https?|s?ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(url)

clearErrorMarkers = (formGroupFinder) ->
  formGroup = $(formGroupFinder)
  formGroup.removeClass('has-error has-feedback')
  formGroup.find('span').addClass('hidden')

addErrorMarkers = (formGroupFinder, errorHint) ->
  formGroup = $(formGroupFinder)
  formGroup.addClass('has-error has-feedback')
  formGroup.find('span.form-control-feedback').removeClass('hidden')

  if errorHint
    $('#url-help').removeClass('hidden').html(errorHint)

handleLinkAddition = ->
  $('#add-link-button').click(->
    linkTitle = $('#timeline_event_link_title').val()
    linkURL = $('#timeline_event_link_url').val()
    linkURLValid = isUrlValid(linkURL)

    if linkURL and linkURLValid and linkTitle
      exports.addButtonClicked = true
      $('#add-link-modal').modal('hide')
      $('#add-link').find('span').html(linkTitle)
      $('#add-link').addClass('green-text')
    else
      unless linkURL and linkURLValid
        addErrorMarkers('#link-url-group', "Please make sure you've supplied a full URL, starting with http(s).")

      unless linkTitle
        addErrorMarkers('#link-title-group')
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

matchDescriptionScroll = (target) ->
  $('span.text-area-overlay').scrollTop(target.scrollTop())

measureDescriptionLength = ->
  $('#timeline_event_description').on('input', (event) ->
    description = $(event.target)

    # Let's escape the incoming text, before manipulating it.
    unescapedDescriptionText = description.val()
    descriptionText = $('<div/>').text(unescapedDescriptionText).html();
    span_contents = descriptionText

    if span_contents
      span_contents += " &mdash; (#{unescapedDescriptionText.length}/300)"

      if descriptionText.length >= 250
        $('span.text-area-overlay').addClass 'length-warning'
      else
        $('span.text-area-overlay').removeClass 'length-warning'

    textAreaOverlay = $('span.text-area-overlay')

    # Replace contents of overlay span.
    textAreaOverlay.html(span_contents)

    # Match scroll of overlay with textbox, in case it has scrolled to a new line.
    matchDescriptionScroll($(description))

    # TODO: Match height of textbox with overlay, in case overlay (which is has a few extra text characters) has line-break-ed, and textbox has not (which would hide the extra overlay content outside scroll area).
  )

  $("#timeline_event_description").scroll((event) ->
    matchDescriptionScroll($(event.target))
  )

setPendingTooltips = ->
  $('.pending-verification').tooltip()

$(timelineBuilderSubmitChecks)
$(setupSelect2ForEventType)
$(clearErrorsOnOpeningSelect2)
$(handleDateButtonClick)
$(closeDatePickerOnExternalClick)
$(handleImageUpload)
$(handleLinkAddition)
$(measureDescriptionLength)
$(setPendingTooltips)
$(matchSampleTextToEventType)
