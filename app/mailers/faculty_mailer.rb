# Mails sent out to coaches.
class FacultyMailer < SchoolMailer
  # Mail sent to faculty once a connect request is confirmed.
  #
  # @param connect_request [ConnectRequest] Request that was just confirmed
  def connect_request_confirmed(connect_request)
    @connect_request = connect_request
    @school = connect_request.faculty.school
    simple_roadie_mail(connect_request.faculty.email, "Office hour confirmed.")
  end

  def request_next_week_slots(faculty)
    @faculty = faculty
    @school = faculty.school

    simple_roadie_mail(faculty.email, 'Connect slots for the upcoming week')
  end

  # Mail sent a little while after the a confirmed connect request meeting occurred.
  #
  # @param connect_request [ConnectRequest] Request for a meeting which recently occurred.
  def connect_request_feedback(connect_request)
    @connect_request = connect_request
    @faculty = connect_request.faculty
    @startup = connect_request.startup
    @school = @faculty.school

    simple_roadie_mail(@faculty.email, "Feedback for your recent office hour with team members of #{@startup.display_name}")
  end

  # Mail sent after a student submits a timeline event.
  #
  # @param timeline_event [TimelineEvent] Timeline event that was created just now.
  # @param faculty [Faculty] Coach who needs to be notified about the submission.
  def student_submission_notification(timeline_event, faculty)
    @faculty = faculty

    @submission_from = if timeline_event.founders.count == 1
      # TODO: Replace with pick(:name) with Rails 6.
      timeline_event.founders.first.name
    else
      "team #{timeline_event.founders.first.startup.name}"
    end

    @startup = timeline_event.startup
    @target = timeline_event.target
    @school = faculty.school

    simple_roadie_mail(faculty.email, "There is a new submission from #{@startup.name}")
  end
end
