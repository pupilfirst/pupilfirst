registerTooltips = ->
  $('#verified-icon').tooltip()

handleReadFromBeginning = ->
  $('#read-from-beginning').click ->
    $("#timeline-list")[0].lastChild.scrollIntoView(false)
    return false

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


moveToSpecifiedEvent = ->
  if $(".main-timeline").length && $(".main-timeline").data('timelineEventId')
    window.location.hash = "#event-" + $(".main-timeline").data('timelineEventId')

$(document).on 'turbolinks:load', ->
  if $('#startups__show').length
    registerTooltips()
    handleReadFromBeginning()
    showDefaultFeedback()
    handleShowFeedbackClick()
    resetOnHideFeedbackModal()
    moveToSpecifiedEvent()
