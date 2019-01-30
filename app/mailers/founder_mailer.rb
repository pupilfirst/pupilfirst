class FounderMailer < ApplicationMailer
  # Mail sent a little while after the a confirmed connect request meeting occured.
  #
  # @param connect_request [ConnectRequest] Request for a meeting which recently occurred.
  def connect_request_feedback(connect_request)
    @connect_request = connect_request
    @faculty = connect_request.faculty
    # TODO: Do we need to send this to each founder?
    @founder = connect_request.startup.founders.first
    mail(to: @founder.email, subject: "Feedback for your recent office hour with coach #{@faculty.name}")
  end

  # Inform founder when he is removed from slack due to subscription expiry
  def slack_removal(founder)
    @founder = founder
    mail(to: @founder.email, subject: 'Your SV.CO Slack membership has been revoked!')
  end
end
