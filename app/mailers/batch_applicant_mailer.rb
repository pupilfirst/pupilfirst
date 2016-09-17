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

  def application_rejection(batch, _stage, batch_application)
    @batch = batch
    @batch_application = batch_application.decorate
    mail(to: batch_application.team_lead.email, subject: 'Your application to SV.CO has not been selected to the next stage!')
  end

  def swept(team_lead, batch)
    @team_lead = team_lead
    @batch = batch
    mail(to: team_lead.email, subject: "Reapply to Batch ##{batch.batch_number} at SV.CO")
  end
end
