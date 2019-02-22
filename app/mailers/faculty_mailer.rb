# Mails sent out to coaches.
class FacultyMailer < SchoolMailer
  # Mail sent to faculty once a connect request is confirmed.
  #
  # @param connect_request [ConnectRequest] Request that was just confirmed
  def connect_request_confirmed(connect_request)
    @connect_request = connect_request
    @school = connect_request.faculty.school
    roadie_mail({ from: from(@school), to: connect_request.faculty.email, subject: 'Office hour confirmed.' }, roadie_options_for(@school))
  end

  def request_next_week_slots(faculty)
    @faculty = faculty
    mail(to: faculty.email, subject: 'Connect slots for the upcoming week')
  end

  # Mail sent a little while after the a confirmed connect request meeting occurred.
  #
  # @param connect_request [ConnectRequest] Request for a meeting which recently occurred.
  def connect_request_feedback(connect_request)
    @connect_request = connect_request
    @faculty = connect_request.faculty
    @startup = connect_request.startup
    mail(to: @faculty.email, subject: "Feedback for your recent office hour with team members of #{@startup.display_name}")
  end

  # Mail sent after a student submits a timeline event.
  #
  # @param timeline_event [TimelineEvent] Timeline event that was created just now.
  def student_submission_notification(timeline_event, faculty)
    @submission_from = if timeline_event.founders.load.size == 1
      timeline_event.founders.first.name
    else
      "team #{timeline_event.founders.first.startup.product_name}"
    end

    @startup = timeline_event.startup
    @faculty = faculty
    @target = timeline_event.target
    mail(to: @faculty.email, subject: "There is a new submission from #{@startup.product_name}")
  end
end
