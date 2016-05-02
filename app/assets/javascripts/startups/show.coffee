$(document).on 'page:change', ->
  $('#verified-icon').tooltip()
  $('.truncated-founder-name').tooltip()

  $('.timeline-container').masonry
    itemSelector: '.timeline-item'

Align_Badge = ->
  timelineItems = $('.timeline-container').find('.timeline-item')
  $.each timelineItems, (index, item) ->
    timelineItem = $(item)
    timelineBadge = timelineItem.find('.timeline-badge')
    posLeft = timelineItem.css('left')

    if posLeft == '0px'
      timelineBadge.addClass('right-aligned')
      timelineItem.addClass('left-item')
    else
      timelineBadge.addClass('left-aligned')
      timelineItem.addClass('right-item')

$(document).on 'page:change', ->
  $('#targets-tab').tabCollapse
    tabsClass: 'hidden-md hidden-sm hidden-xs',
    accordionClass: 'visible-md visible-sm visible-xs'

  $('#pending-targets-list .panel-collapse:first').addClass('in');
  $('#expired-targets-list .panel-collapse:first').addClass('in');
  $('#completed-targets-list .panel-collapse:first').addClass('in');

$(document).on 'page:change', ->
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

$(document).on 'page:change', ->
  $('#read-from-beginning').click(->
    document.getElementById("timeline-list").lastChild.scrollIntoView(false)
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

$(document).on 'page:change', ->
  $("#new-event-form .panel-heading").click(->
    $("#new-event-form .panel-body").collapse('toggle')
    $("#new-event-form .fa-plus").toggleClass("hidden")
    $("#new-event-form .fa-minus").toggleClass("hidden")
  )

timelineBuilderSubmitChecks = ->
  $('form.new_timeline_event, form.edit_timeline_event').submit((event) ->
    # Don't allow form submit to proceed. We're going to do it with AJAX instead.
    event.preventDefault()

    form = $(event.target)

    typeOfEventPresent = !!form.find('select#timeline_event_timeline_event_type_id').val()
    dateOfEventPresent = !!form.find('input#timeline_event_event_on').val()
    descriptionPresent = !!form.find('#timeline_event_description').val()

    unless descriptionPresent
      timelineEventDescription = $('#timeline_event_description')
      timelineEventDescription.attr('placeholder', 'You must supply a description!')
      timelineEventDescription.addClass('has-error')

    unless dateOfEventPresent
      timelineEventDateField = $('#timeline_event_event_on')
      timelineEventDateField.addClass('has-error')

      timelineEventDateField.tooltip(
        placement: 'bottom',
        title: 'When did this event occur?',
        trigger: 'manual'
      )

      timelineEventDateField.tooltip('show')

    unless typeOfEventPresent
      select2Container = form.find('.select2-container')
      select2Container.addClass('has-error')

      select2Container.tooltip(
        placement: 'top',
        title: 'What type of event is this?',
        trigger: 'manual'
      )

      select2Container.tooltip('show')

    if form.data('verified') && !form.data('private')
      confirmedByUser = confirm('This will hide event from public until change is verified by SV.CO team. Continue?')
    else
      confirmedByUser = true

    if typeOfEventPresent && dateOfEventPresent && descriptionPresent && confirmedByUser
      submitWithProgressReport(event)
  )

submitWithProgressReport = (event) ->
  form = $(event.target)
  formData = new FormData(form[0])

  # Disable the submit button.
  submitButtonInProgress()

  # Submit form data using AJAX and set a progress handler function.
  $.ajax(
    url: form.attr('action'),
    type: form.attr('method'),
    xhr: ->
      myXhr = $.ajaxSettings.xhr()

      if myXhr.upload # Check if upload property exists
        myXhr.upload.addEventListener 'progress', progressHandlingFunction, false # For handling the progress of the upload

      myXhr
    ,

    # Ajax events.
    beforeSend: beforeSendHandler,
    success: completeHandler,
    error: errorHandler,

    # Form data
    data: formData,

    # Options to tell jQuery not to process data or worry about content-type.
    cache: false,
    contentType: false,
    processData: false
  )

submitButtonInProgress = ->
  submitButton = $('#timeline-builder-submit-button')
  submitButton.prop('disabled', true).addClass('disabled')
  submitButton.find('.submit-timeline-builder-icon > i').prop('class', 'fa fa-spinner fa-pulse')

progressHandlingFunction = (event) ->
  if event.lengthComputable
    $('progress.timeline-event-upload-progress').attr(value: event.loaded, max: event.total)

    if event.loaded != event.total
      percentDone = Math.round((event.loaded / event.total) * 100)

      if event.total >= 1024
        loadedKB = Math.round(event.loaded / 1024)
        totalKB = Math.round(event.total / 1024)
      else
        totalKB = false

      progressText = $('.timeline-event-upload-progress-text')
      updatedProgressText = "Uploading data... #{percentDone}%"

      if totalKB
        updatedProgressText += " (#{loadedKB} KB of #{totalKB} KB)"

      progressText.html updatedProgressText

beforeSendHandler = ->
  progressSection = $('section.timeline-event-upload-progress-section')
  progressSection.show()

completeHandler = ->
  progressText = $('.timeline-event-upload-progress-text')
  progressText.html 'All done! Refreshing timeline&hellip;'

  setTimeout ->
    window.location = window.location.pathname
  , 2000

errorHandler = ->
  progressText = $('.timeline-event-upload-progress-text')
  progressText.html 'Something went wrong. Please try again after a little while, or contact us at help@sv.co.'

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
      element.select2.defaults.matcher(term, text) || element.select2.defaults.matcher(term,
        opt.parent("optgroup").attr("label"))
  )

matchSampleTextToEventType = ->
  $('#timeline_event_timeline_event_type_id').on('select2-selected', (e) ->
    newPlaceHolder = $('#timeline_event_timeline_event_type_id :selected').attr("data-sample-text")
    $('#timeline_event_description').attr("placeholder", newPlaceHolder)
  )

removeSelectedImage = ->
  uploadImage = $('#upload-image')
  uploadImage.removeClass('green-text')
  uploadImage.find('span').html('Add an Image')
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

markSelectedAttachments = ->
  $('#timeline_event_links').change ->
    updateAttachmentsTabTitle()

  $('#timeline_event_files_metadata').change ->
    updateAttachmentsTabTitle()

updateAttachmentsTabTitle = ->
  links = if !$('#timeline_event_links').val() then [] else JSON.parse $('#timeline_event_links').val()
  files = if !$('#timeline_event_files_metadata').val() then [] else JSON.parse $('#timeline_event_files_metadata').val()

  # Remove files marked for deletion.
  files = $.map files, (file) ->
    if file['delete']
      null
    else
      file

  title = ''
  extraAttachments = 0

  if files.length > 0
    title = files[0].title

    extraAttachments = files.length - 1
    extraAttachments += links.length
  else if links.length > 0
    title = links[0].title

    extraAttachments = links.length - 1
  else
    title = 'Add Links and Files'

  if extraAttachments > 0
    title += " (+#{extraAttachments})"

  $('#add-link').find('span').html(title)

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
  $("#timeline-builder-datepicker-box").DateTimePicker(
    dateFormat: "YYYY-MM-DD",
    maxDate: moment().format('YYYY-MM-DD'),
    afterShow: ->
      # Remove error class and tooltip on it if its present
      timelineEventDateField = $('#timeline_event_event_on')
      timelineEventDateField.removeClass('has-error')
      timelineEventDateField.tooltip('destroy')
  )

handleShowFeedbackClick = ->
  $('.show-feedback-button').click (event) ->
    feedback = $(event.target).data('feedback')
    faculty = $(event.target).data('faculty')
    attachmentName = $(event.target).data('attachment-name')
    attachmentUrl = $(event.target).data('attachment-url')
    openFeedbackModel(feedback, faculty, attachmentName, attachmentUrl)

openFeedbackModel = (feedback, faculty, attachmentName, attachmentUrl) ->
  $('#improvement-modal').find('.feedback-text').html("<pre>#{feedback}</pre>")
  $('#improvement-modal').find('.modal-title').html("Feedback from #{faculty}")
  if attachmentUrl
    $('#improvement-modal').find('.attachment').removeClass('hidden')
    $('#improvement-modal').find('.attachment-name').html(" #{attachmentName}")
    $('#improvement-modal').find('.attachment-download-btn').attr('href', "#{attachmentUrl}")
  $('#improvement-modal').modal('show')

showDefaultFeedback = ->
  if $('#improvement-modal') and $('#improvement-modal').data('feedback') and $('#improvement-modal').data('faculty')
    feedback = $('#improvement-modal').data('feedback')
    faculty = $('#improvement-modal').data('faculty')
    attachmentName = $('#improvement-modal').data('attachment-name')
    attachmentUrl = $('#improvement-modal').data('attachment-url')
    openFeedbackModel(feedback, faculty, attachmentName, attachmentUrl)

resetOnHideFeedbackModal = ->
  $('#improvement-modal').on 'hidden.bs.modal', (event) ->
    $('#improvement-modal').find('.feedback-text').html("")
    $('#improvement-modal').find('.modal-title').html("")
    $('#improvement-modal').find('.attachment').addClass("hidden")
    $('#improvement-modal').find('.attachment-name').html("")
    $('#improvement-modal').find('.attachment-download-btn').attr('href', "")


addTooltipToHideCheckbox = ->
  $("#hide-from-public").tooltip()

giveATour = ->
  startTour() if $('#startup-show-tour').data('tour-flag')


startTour = ->
  startupShowTour = $('#startup-show-tour')

  tour = introJs()

  tour.setOptions(
    skipLabel: 'Close',
    steps: [
      {
        element: $('h1.product-name')[0],
        intro: startupShowTour.data('intro')
      },
      {
        element: $('.timeline-builder')[0],
        intro: startupShowTour.data('timelineBuilder')
      },
      {
        element: $('.timeline-panel')[0],
        intro: startupShowTour.data('timelineEvent')
      },
      {
        element: $('#targets')[0],
        intro: startupShowTour.data('targets')
      },
      {
        element: $('.data-icons')[0],
        intro: startupShowTour.data('dataPoints')
      },
      {
        element: $('.data-founder')[0],
        intro: startupShowTour.data('founders')
      }
    ]
  )

  tour.onexit enableTourButton
  tour.oncomplete enableTourButton
  disableTourButton()
  tour.start()

disableTourButton = ->
  tourButton = $('button.tour-button')
  tourButton.tooltip('destroy')
  tourButton.attr('disabled', true)

enableTourButton = ->
  tourButton = $('button.tour-button')
  tourButton.removeAttr('disabled')
  tourButton.tooltip()

handleTourButtonClick = ->
  $('#tour-button').on 'click', ->
    startTour()

$(document).on 'page:change', timelineBuilderSubmitChecks
$(document).on 'page:change', setupSelect2ForEventType
$(document).on 'page:change', clearErrorsOnOpeningSelect2
$(document).on 'page:change', handleImageUpload
$(document).on 'page:change', measureDescriptionLength
$(document).on 'page:change', setPendingTooltips
$(document).on 'page:change', matchSampleTextToEventType
$(document).on 'page:change', setupTimelineBuilderDatepicker
$(document).on 'page:change', handleShowFeedbackClick
$(document).on 'page:change', showDefaultFeedback
$(document).on 'page:change', resetOnHideFeedbackModal
$(document).on 'page:change', addTooltipToHideCheckbox
$(document).on 'page:change', markSelectedAttachments
$(document).on 'page:change', updateAttachmentsTabTitle
$(document).on 'page:change', giveATour
$(document).on 'page:change', handleTourButtonClick
$(document).on 'page:change', Align_Badge
