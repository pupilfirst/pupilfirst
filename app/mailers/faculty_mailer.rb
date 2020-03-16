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
end
