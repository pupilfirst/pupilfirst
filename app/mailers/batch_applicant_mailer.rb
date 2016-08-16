class BatchApplicantMailer < ApplicationMailer
  def sign_in(team_lead, shared_device)
    @team_lead = team_lead
    @shared_device = shared_device
    mail(to: team_lead.email, subject: 'Continue application at SV.CO')
  end

  def application_progress(batch, stage, team_lead)
    @batch = batch
    @stage = stage
    mail(to: team_lead.email, subject: 'Your application to SV.CO has moved to the next stage!')
  end

  def application_rejection(batch, stage, team_lead)
    @batch = batch
    @stage = stage
    mail(to: team_lead.email, subject: 'Your application to SV.CO has not been selected to the next stage!')
  end
end
