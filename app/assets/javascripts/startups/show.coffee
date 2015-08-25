exports = {
  timelineBuilderDatepicker: null
}

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

handleDatepickerChangeDate = (e) ->
  timelineBuilderDateButton = $('#timeline-builder-date-button')

  # Store the time in form field.
  timelineBuilderDateButton.find('input').val(e.date.format('YYYY-MM-DD'))

  # Hide the datepicker.
  exports.timelineBuilderDatepicker.hide()

  # Set new date on datepicker button.
  timelineBuilderDateButton.find('.fa-calendar').addClass('hidden')
  timelineBuilderDateButton.find('.fa-calendar-check-o').removeClass('hidden')
  timelineBuilderDateButton.find('a').addClass('green')
  timelineBuilderDateButton.find('#date-of-event').html('&nbsp;' + e.date.format('DD/MM/YYYY'))

timelineBuilderSubmitChecks = ->
  $('form.new_timeline_event, form.edit_timeline_event').submit((event) ->
    form = $(event.target)

    typeOfEventPresent = !!form.find('select#timeline_event_timeline_event_type_id').val()
    dateOfEventPresent = !!form.find('input#timeline_event_event_on').val()
    descriptionPresent = !!form.find('#timeline_event_description').val()

    unless descriptionPresent
      timelineEventDescription = $('#timeline_event_description')
      timelineEventDescription.attr('placeholder', 'You must supply a description!')
      timelineEventDescription.addClass('has-error')

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

    if form.data('persisted')
      confirmedByUser = confirm('This will hide event from public until change is verified by SV.CO team. Continue?')
    else
      confirmedByUser = true

    return false unless typeOfEventPresent && dateOfEventPresent && descriptionPresent && confirmedByUser
  )

clearErrorsOnOpeningSelect2 = ->
  $('#timeline_event_timeline_event_type_id').on('select2-opening', ->
    select2Container = $('form.new_timeline_event .select2-container, form.edit_timeline_event .select2-container')
    select2Container.removeClass('has-error')
    select2Container.tooltip('destroy')
  )

setupSelect2ForEventType = ->
  $('#timeline_event_timeline_event_type_id').select2(
    placeholder: "Type of Event",
    matcher: (term, text, opt) ->
      # This matcher has been picked up from SO. It lets the Select2 finder search for optgroup labels as well.
      # TODO: This custom finder will probably break with Select2 is updated to v4.
      # See http://stackoverflow.com/questions/21992727/display-result-matching-optgroup-using-select2#comment50370609_21996758
      element = $('#timeline_event_timeline_event_type_id')
      element.select2.defaults.matcher(term, text) || element.select2.defaults.matcher(term, opt.parent("optgroup").attr("label"))
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

    # Toggle the datepicker itself.
    exports.timelineBuilderDatepicker.toggle()
  )

closeDatePickerOnExternalClick = ->
  $(document).on('click', (event) ->
    eventTarget = $(event.target)

    if exports.timelineBuilderDatepicker
      unless $(event.target).closest('#timeline-builder-date-button').length
        exports.timelineBuilderDatepicker.toggle(false)
  )

removeSelectedLink = ->
  $('#timeline_event_link_title').val('')
  $('#timeline_event_link_url').val('')
  markSelectedLink('Add a URL', true)

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

markSelectedLink = (linkTitle, unmark=false) ->
  $('#add-link').find('span').html(linkTitle)

  if unmark
    $('#add-link').removeClass('green-text')
    $('#remove-selected-link').addClass('hidden')
  else
    $('#add-link').addClass('green-text')
    $('#remove-selected-link').removeClass('hidden')

# If link title and URL are set on load (editing), then we start with selected values.
markSelectedLinksOnEdit = ->
  linkTitle = $('#timeline_event_link_title').val()
  linkURL = $('#timeline_event_link_url').val()

  # Check if both are available on page load - which means we're editing, so set the title on builder link.
  if linkURL and linkTitle
    markSelectedLink(linkTitle)

handleLinkAddition = ->
  # When the modal opens, load value saved in actual hidden inputs.
  $('#add-link-modal').on('show.bs.modal', (e) ->
    linkTitle = $('#timeline_event_link_title').val()
    linkURL = $('#timeline_event_link_url').val()

    $('#link_title_front').val(linkTitle)
    $('#link_url_front').val(linkURL)
  )

  # When the add button is clicked, validate and store if it passes. Show errors otherwise.
  $('#add-link-button').click(->
    linkTitle = $('#link_title_front').val()
    linkURL = $('#link_url_front').val()
    linkURLValid = isUrlValid(linkURL)

    if linkURL and linkURLValid and linkTitle
      # Store values in hidden inputs, close modal, and show title on builder link.
      $('#timeline_event_link_title').val(linkTitle)
      $('#timeline_event_link_url').val(linkURL)
      $('#add-link-modal').modal('hide')
      markSelectedLink(linkTitle)
    else
      unless linkURL and linkURLValid
        addErrorMarkers('#link-url-group', "Please make sure you've supplied a full URL, starting with http(s).")

      unless linkTitle
        addErrorMarkers('#link-title-group')
  )

  $('#link_title_front').focus(->
    clearErrorMarkers('#link-title-group')
  )

  $('#link_url_front').focus(->
    clearErrorMarkers('#link-url-group')
  )

  $('#add-link-modal').on('hide.bs.modal', (e) ->
    clearErrorMarkers('#link-title-group')
    clearErrorMarkers('#link-url-group')
  )

  $('#remove-selected-link').click(removeSelectedLink)

matchDescriptionScroll = (target) ->
  $('span.text-area-overlay').scrollTop(target.scrollTop())

measureDescriptionLength = ->
  $('#timeline_event_description').on('input', (event) ->
    description = $(event.target)

    # Remove error class on it, if present.
    description.removeClass('has-error')

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

pad = (val, length, padChar = '0') ->
  val += ''
  numPads = length - val.length
  if (numPads > 0) then new Array(numPads + 1).join(padChar) + val else val

setupTimelineBuilderDatepicker = ->
  timelineBuilderDateButton = $('#timeline-builder-date-button')

  if timelineBuilderDateButton
    datepickerContainer = timelineBuilderDateButton.find('.datepicker-container')

    exports.timelineBuilderDatepicker = datepickerContainer.datetimepicker(
      format: 'DD/MM/YYYY',
      maxDate: moment(),
      inline: true
    )

    exports.timelineBuilderDatepicker.on('dp.change', handleDatepickerChangeDate)

    eventDate = $('#timeline_event_event_on').val()

    # If an event date is already set (editing), set that in the datepicker, and in the button.
    if eventDate
      dateComponents = (parseInt(num) for num in eventDate.split('-'))

      year = dateComponents[0]
      month = dateComponents[1]
      day = dateComponents[2]

      # Date() is weird in that it counts months from zero onwards.
      dateFromServer = new Date(year, month - 1, day)

      # Change the date inside datepicker (this will emit dp.change event).
      datepickerContainer.data("DateTimePicker").date(dateFromServer)

$(timelineBuilderSubmitChecks)
$(setupSelect2ForEventType)
$(clearErrorsOnOpeningSelect2)
$(handleDateButtonClick)
$(closeDatePickerOnExternalClick)
$(handleImageUpload)
$(handleLinkAddition)
$(markSelectedLinksOnEdit)
$(measureDescriptionLength)
$(setPendingTooltips)
$(matchSampleTextToEventType)
$(setupTimelineBuilderDatepicker)
