class BatchApplicantMailerPreview < ActionMailer::Preview
  def sign_in
    team_lead = BatchApplicant.first
    BatchApplicantMailer.sign_in(team_lead, false)
  end

  def application_progress
    batch = Batch.where.not(application_stage_id: nil).first
    team_lead = BatchApplicant.first
    BatchApplicantMailer.application_progress(batch, team_lead)
  end

  def swept
    application = BatchApplication.first
    team_lead = application.team_lead
    batch = application.batch
    BatchApplicantMailer.swept(team_lead, batch)
  end
end
