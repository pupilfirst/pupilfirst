class EmailApplicantsJob < ActiveJob::Base
  queue_as :default

  def perform(batch)
    @batch = batch
    applications_for_batch = BatchApplication.where(batch: batch)

    # Send emails to team leads who got through.
    selected_applications = applications_for_batch.where(application_stage: batch.application_stage)
    send_application_progress_mails(selected_applications)

    # Send rejection emails to team leads who didn't get through
    rejected_applications = applications_for_batch
      .joins(:application_stage)
      .where('application_stages.number < ?', batch.application_stage.number)
      .where.not(application_stages: { number: 1 })

    send_application_rejection_mails(rejected_applications)
  end

  def send_application_progress_mails(applications)
    applications.each do |application|
      next unless application.team_lead.present?

      BatchApplicantMailer.application_progress(
        @batch,
        application.team_lead
      ).deliver_later
    end
  end

  def send_application_rejection_mails(applications)
    applications.each do |application|
      next unless application.team_lead.present?

      BatchApplicantMailer.application_rejection(
        @batch,
        application.team_lead
      ).deliver_later
    end
  end
end
