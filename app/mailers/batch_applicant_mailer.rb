class BatchApplicantMailer < ApplicationMailer
  def application_progress(batch, stage, team_lead)
    @batch = batch
    @stage = stage
    mail(to: team_lead.email, subject: 'Your application to SV.CO has moved to the next stage!')
  end

  def application_rejection(batch, _stage, batch_application)
    @batch = batch
    @batch_application = batch_application.decorate
    mail(to: batch_application.team_lead.email, subject: "SV.CO batch #{@batch.batch_number} results are out!")
  end

  def swept(batch_application)
    @team_lead = batch_application.team_lead
    @application_round = batch_application.application_round
    mail(to: @team_lead.email, subject: "Reapply to #{@application_round.display_name} at SV.CO")
  end

  def swept_skip_payment(batch_application)
    @team_lead = batch_application.team_lead
    mail(to: @team_lead.email, subject: 'Your chance to reapply at SV.CO, for FREE!')
  end

  def referral_refund(referrer, applicant)
    @referrer = referrer
    @applicant = applicant
    mail(to: referrer.email, subject: 'You have a successful referral at SV.CO!')
  end
end
