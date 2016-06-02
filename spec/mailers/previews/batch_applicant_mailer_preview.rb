class BatchApplicantMailerPreview < ActionMailer::Preview
  def sign_in
    email = 'test@sv.co'
    token = 'TOKEN1234'
    batch = Batch.first
    BatchApplicantMailer.sign_in(email, token, batch)
  end

  def application_progress
    batch = Batch.where.not(application_stage_id: nil).first
    team_lead = BatchApplicant.first
    BatchApplicantMailer.application_progress(batch, team_lead)
  end
end
