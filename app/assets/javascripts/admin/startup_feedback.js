$(function(){
  $('#startup_feedback_startup_id').select2({ placeholder : 'Select Startup' });
  $('#startup_feedback_startup_id').change(showStartupFeedback);
  showStartupFeedback();
});


function showStartupFeedback(){
  var startup_id = $('#startup_feedback_startup_id').val();
  if (startup_id.length > 0) {
    $.get("/admin/startups/"+startup_id+"/get_all_startup_feedback",onSuccess);
  } else {
    $("#feedback-table").hide();
  }
}

function onSuccess (data,status) {
  if (data.feedback.length > 0) {
    $("#feedback-table").show();
    $("#feedback-list-title").html("Previous Feedback for "+data.startup_name);
    $("#feedback-table-body").html("");
    $.each(data.feedback,appendRow);
    $( "tr:odd" ).addClass("odd");
    $( "tr:even" ).addClass("even");
  } else {
    $("#feedback-list-title").html(data.startup_name+" has no previous feedback.");
    $("#feedback-table").hide();
  }
}

function appendRow (index,feedback) {
  var viewLinkHTML = "<td><a href='https://sv.co/admin/startup_feedback/"+feedback.id+"'>View</a></td>"; //works only in production!
  var feedbackHTML = "<td><pre class='startup-feedback'>"+feedback.feedback+"</pre></td>";
  var referenceUrlHTML = "<td><a href='"+feedback.reference_url+"'>Link</a></td>";
  if (feedback.send_at == null) {
    var send_at_entry = "Not yet sent!";
  } else {
    // jquery-ui already has a formatDate. Hence, using that
    var send_at_entry = $.datepicker.formatDate('dd MM yy',new Date(feedback.send_at));
  }
  var sendAtHTML = "<td>"+send_at_entry+"</td>";
  var trHTML = "<tr>"+viewLinkHTML+feedbackHTML+referenceUrlHTML+sendAtHTML+"</tr>";
  $("#feedback-table-body").append(trHTML);
}
