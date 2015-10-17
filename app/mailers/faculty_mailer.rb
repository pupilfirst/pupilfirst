# Mails sent out to members of the faculty.
class FacultyMailer < ApplicationMailer
  # Mail sent to faculty once a connect request is confirmed.
  #
  # @param connect_request [ConnectRequest] Request that was just confirmed
  def connect_request_confirmed(connect_request)
    @connect_request = connect_request
    mail(to: connect_request.faculty.email, subject: 'Connect Request confirmed.')
  end
end
