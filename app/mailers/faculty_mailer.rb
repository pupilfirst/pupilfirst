# Mails sent out to members of the faculty.
class FacultyMailer < ApplicationMailer
  # Mail sent to faculty once a connect request is confirmed.
  #
  # @param connect_request [ConnectRequest] Request that was just confirmed
  def connect_request_confirmed(connect_request)
    @connect_request = connect_request
    mail(to: connect_request.faculty.email, subject: 'Connect Request confirmed.')
  end

  def request_next_week_slots(faculty)
    @faculty = faculty
    mail(to: faculty.email, subject: 'Connect slots for the upcoming week')
  end

  # Mail sent a little while after the a confirmed connect request meeting occured.
  #
  # @param connect_request [ConnectRequest] Request for a meeting which recently occurred.
  def connect_request_feedback(connect_request)
    @connect_request = connect_request
    @faculty = connect_request.faculty
    @startup = connect_request.startup
    mail(to: @faculty.email, subject: "Feedback for your recent faculty connect session with team members of #{@startup.display_name}")
  end
end
