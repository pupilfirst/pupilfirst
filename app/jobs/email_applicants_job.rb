class EmailApplicantsJob < ActiveJob::Base
  queue_as :default

  def perform(batch)
    @batch = batch
    applications_for_batch = BatchApplication.where(batch: batch)

    # Figure out which is the latest active stage for given batch.
    active_stages = batch.batch_stages.select(&:active?)
    stage_number = 0

    active_stages.each do |batch_stage|
      if batch_stage.application_stage.number > stage_number
        @latest_stage = batch_stage.application_stage
        stage_number = batch_stage.application_stage.number
      end
    end

    # Send emails to team leads who got through.
    selected_applications = applications_for_batch.where(application_stage: @latest_stage)
    send_application_progress_mails(selected_applications)

    # Send rejection emails to team leads who didn't get through (except for those in stage 1).
    if @latest_stage.previous.number > 1
      rejected_applications = applications_for_batch
        .joins(:application_stage)
        .where('application_stages.number = ?', @latest_stage.previous.number)

      send_application_rejection_mails(rejected_applications)
    end
  end

  def send_application_progress_mails(applications)
    applications.each do |application|
      next unless application.team_lead.present?

      BatchApplicantMailer.application_progress(
        @batch,
        @latest_stage,
        application.team_lead
      ).deliver_later
    end
  end

  def send_application_rejection_mails(applications)
    applications.each do |application|
      next unless application.team_lead.present?

      BatchApplicantMailer.application_rejection(
        @batch,
        @latest_stage,
        application.team_lead
      ).deliver_later
    end
  end
end
