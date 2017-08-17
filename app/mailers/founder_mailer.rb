class FounderMailer < ApplicationMailer
  # Mail sent a little while after the a confirmed connect request meeting occured.
  #
  # @param connect_request [ConnectRequest] Request for a meeting which recently occurred.
  def connect_request_feedback(connect_request)
    @connect_request = connect_request
    @faculty = connect_request.faculty
    @founder = connect_request.startup.admin
    mail(to: @founder.email, subject: "Feedback for your recent faculty connect session with faculty member #{@faculty.name}")
  end

  def referral_reward(referrer, applicant)
    @referrer = referrer
    @applicant = applicant
    mail(to: referrer.email, subject: 'You have a successful referral at SV.CO!')
  end

  # Invite an applicant founder to join a startup.
  def invite(founder, startup)
    @founder = founder
    @startup = startup

    mail(to: founder.email, subject: 'You have been invited to join a startup at SV.CO')
  end
end
