class FounderMailer < ApplicationMailer
  # Mail sent a little while after the a confirmed connect request meeting occured.
  #
  # @param connect_request [ConnectRequest] Request for a meeting which recently occurred.
  def connect_request_feedback(connect_request)
    @connect_request = connect_request
    @faculty = connect_request.faculty
    @founder = connect_request.startup.team_lead
    mail(to: @founder.email, subject: "Feedback for your recent office hour with faculty member #{@faculty.name}")
  end

  # Invite an applicant founder to join a startup.
  def invite(founder, startup)
    @founder = founder
    @startup = startup

    mail(to: founder.email, subject: 'You have been invited to join a team at SV.CO')
  end

  # Inform founder when he is removed from slack due to subscription expiry
  def slack_removal(founder)
    @founder = founder
    mail(to: @founder.email, subject: 'Your SV.CO Slack membership has been revoked!')
  end
end
