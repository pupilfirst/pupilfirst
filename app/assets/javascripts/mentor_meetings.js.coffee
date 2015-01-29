# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

exports = this

exports.require_comments_for_reject = (meeting_id) ->
  mentor_comments = $("#mentor-comments-#{ meeting_id }")
  mentor_alert = $("#comments-empty-alert-#{ meeting_id }")

  if mentor_comments.val().trim() == ''
    mentor_alert.removeClass('hidden')
    return false
  else
    return true
