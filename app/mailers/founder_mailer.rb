# Mails sent directly to students.
class FounderMailer < SchoolMailer
  # Mail sent a little while after the a confirmed connect request meeting occured.
  #
  # @param connect_request [ConnectRequest] Request for a meeting which recently occurred.
  def connect_request_feedback(connect_request)
    @connect_request = connect_request
    @faculty = connect_request.faculty
    # TODO: Do we need to send this to each founder?
    @founder = connect_request.startup.founders.first
    @school = @founder.school

    simple_roadie_mail(@founder.email, "Feedback for your recent office hour with coach #{@faculty.name}")
  end
end
