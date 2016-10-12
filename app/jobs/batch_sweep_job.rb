class BatchSweepJob < ApplicationJob
  queue_as :default

  def perform(batch_id, sweep_unpaid, sweep_batch_ids, admin_email, skip_payment: false)
    @batch = Batch.find batch_id
    @skip_payment = skip_payment
    raise 'Target batch is not in initial stage' unless @batch.initial_stage?

    sweep_unpaid_applications if sweep_unpaid
    sweep_from_batches(sweep_batch_ids)
    send_email(admin_email)
  end

  def sweep_unpaid_applications
    other_applications = BatchApplication.where.not(batch: @batch)
    uninitiated_applications = other_applications.includes(:payment).where(payments: { id: nil })
    unpaid_applications = other_applications.joins(:payment).merge(Payment.requested)
    count_for_email 'Payment missing applications swept' => uninitiated_applications.count
    count_for_email 'Payment initiated applications swept' => unpaid_applications.count
    (uninitiated_applications + unpaid_applications).each { |application| application.update!(batch_id: @batch.id) }
  end

  def sweep_from_batches(batch_ids)
    sweep_results = batch_ids.each_with_object({}) do |batch_id, results|
      source_batch = Batch.find batch_id
      expired, ignored, rejected = sweep_from_batch(source_batch)
      results["From Batch ##{source_batch.batch_number}"] = { 'Rejected swept' => rejected, 'Expired swept' => expired, 'Ignored' => ignored }
    end

    count_for_email sweep_results
  end

  def sweep_from_batch(source_batch)
    rejected = 0
    expired = 0
    ignored = 0

    source_batch.batch_applications.each do |batch_application|
      if batch_application.swept_at.present? || batch_application.application_stage.initial_stage?
        ignored += 1
        next
      end

      case batch_application.status
        when :rejected
          duplicate_application(batch_application)
          rejected += 1
        when :expired
          duplicate_application(batch_application)
          expired += 1
        else
          ignored += 1
      end
    end

    [expired, ignored, rejected]
  end

  def send_email(admin_email)
    AdminUserMailer.batch_sweep(
      admin_email,
      @batch.batch_number,
      @counts
    ).deliver_later
  end

  def count_for_email(hash)
    @counts ||= {}
    @counts.merge!(hash)
  end

  # Creates a (pristine) duplicate of this application into given batch.
  def duplicate_application(batch_application)
    new_application = BatchApplication.create!(
      batch: @batch,
      team_lead: batch_application.team_lead,
      application_stage: new_application_stage,
      college: batch_application.college,
      team_size: batch_application.team_size
    )

    new_application.batch_applicants << batch_application.team_lead

    batch_application.update!(swept_at: Time.now)

    skip_payment(new_application) if @skip_payment

    # Send email to the lead.
    BatchApplicantMailer.swept(batch_application.team_lead, @batch).deliver_later
  end

  # Create a dummy payment entry and
  def skip_payment(batch_application)
    Payment.create!(
      batch_application: batch_application,
      batch_applicant: batch_application.team_lead,
      paid_at: Time.now,
      notes: 'Payment has been skipped.'
    )
  end

  def new_application_stage
    @skip_payment ? ApplicationStage.testing_stage : ApplicationStage.initial_stage
  end
end
