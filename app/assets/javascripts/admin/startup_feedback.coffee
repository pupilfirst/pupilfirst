$(document).on 'page:change', ->
  $('#startup_feedback_startup_id').select2({ placeholder : 'Select Product' })
  $('#startup_feedback_startup_id').change(showStartupFeedback)
  showStartupFeedback()

  $('#startup_feedback_faculty_id').select2({ placeholder : 'Select Faculty' })

showStartupFeedback = ->
  startup_id = $('#startup_feedback_startup_id').val()
  if startup_id
    $.get("/admin/startups/#{startup_id}/get_all_startup_feedback", onSuccess)
  else
    $("#feedback-table").hide()

onSuccess = (data, status) ->
  if data.feedback
    $("#feedback-table").show()
    $("#feedback-list-title").html("Previous Feedback for #{data.name}")
    $("#feedback-table-body").html("")
    $.each(data.feedback, appendRow)
    $( "tr:odd" ).addClass("odd")
    $( "tr:even" ).addClass("even")
  else
    $("#feedback-list-title").html("#{data.startup_name} has no previous feedback.")
    $("#feedback-table").hide()

appendRow = (index, feedback) ->
  viewLinkHTML = "<td><a href='https://sv.co/admin/startup_feedback/#{feedback.id}'>View</a></td>"; # Works only in production!
  feedbackHTML = "<td><pre class='startup-feedback'>#{feedback.feedback}</pre></td>"
  referenceUrlHTML = "<td><a href='#{feedback.reference_url}'>Link</a></td>"

  if feedback.sent_at
    # jquery-ui already has a formatDate. Hence, using that
    sent_at_entry = $.datepicker.formatDate('dd MM yy',new Date(feedback.sent_at))
  else
    sent_at_entry = "Not yet sent!"

  sendAtHTML = "<td>#{sent_at_entry}</td>"
  trHTML = "<tr>#{viewLinkHTML}#{feedbackHTML}#{referenceUrlHTML}#{sendAtHTML}</tr>"
  $("#feedback-table-body").append(trHTML)
