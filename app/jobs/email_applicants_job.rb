class EmailApplicantsJob < ActiveJob::Base
  queue_as :default

  def perform(batch)
    # Send emails to team leads who got through.
    applications_that_passed = BatchApplication.where(batch: batch, application_stage: batch.application_stage)

    applications_that_passed.each do |application|
      next unless application.team_lead.present?

      BatchApplicantMailer.application_progress(
        batch,
        application.team_lead
      ).deliver_later
    end
  end
end
