class BatchApplicantMailer < ApplicationMailer
  def sign_in(email, token, batch)
    @token = token
    @batch = batch
    mail(to: email, subject: 'One-time application link for SV.CO')
  end

  def application_progress(batch, team_lead)
    @batch = batch
    @stage = batch.application_stage
    mail(to: team_lead.email, subject: 'Your application to SV.CO has moved to the next stage!')
  end
end
