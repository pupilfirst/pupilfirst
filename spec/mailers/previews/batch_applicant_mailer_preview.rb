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

  def application_rejection
    application = BatchApplication.first
    batch = application.batch
    stage = ApplicationStage.testing_stage
    BatchApplicantMailer.application_rejection(batch, stage, application)
  end

  def swept
    application = BatchApplication.first
    team_lead = application.team_lead
    batch = application.batch
    BatchApplicantMailer.swept(team_lead, batch)
  end

  def swept_skip_payment
    application = BatchApplication.first
    team_lead = application.team_lead
    BatchApplicantMailer.swept_skip_payment(team_lead)
  end
end
