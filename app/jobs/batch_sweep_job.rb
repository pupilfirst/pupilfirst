class BatchSweepJob < ApplicationJob
  queue_as :default

  attr_reader :batch

  def perform(batch_id, sweep_unpaid, sweep_batch_ids, admin_email)
    @batch = Batch.find batch_id
    raise 'Target batch is not in initial stage' unless batch.initial_stage?

    sweep_unpaid_applications if sweep_unpaid
    sweep_from_batches(sweep_batch_ids)
    send_email(admin_email)
  end

  def sweep_unpaid_applications
    other_applications = BatchApplication.where.not(batch: batch)
    uninitiated_applications = other_applications.includes(:payment).where(payments: { id: nil })
    unpaid_applications = other_applications.joins(:payment).merge(Payment.requested)
    count_for_email 'Payment missing applications swept' => uninitiated_applications.count
    count_for_email 'Payment initiated applications swept' => unpaid_applications.count
    (uninitiated_applications + unpaid_applications).each { |application| application.update!(batch_id: batch.id) }
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
          batch_application.duplicate!(batch)
          rejected += 1
        when :expired
          batch_application.duplicate!(batch)
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
      batch.batch_number,
      @counts
    ).deliver_later
  end

  def count_for_email(hash)
    @counts ||= {}
    @counts.merge!(hash)
  end
end
