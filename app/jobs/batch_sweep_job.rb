class BatchSweepJob < ApplicationJob
  queue_as :default

  def perform(application_round_id, sweep_unpaid, sweep_round_ids, admin_email, skip_payment: false)
    @application_round = ApplicationRound.find application_round_id
    @skip_payment = skip_payment
    raise 'Target batch is not in initial stage' unless @application_round.initial_stage?

    sweep_unpaid_applications if sweep_unpaid
    sweep_from_rounds(sweep_round_ids)
    send_email(admin_email)
  end

  def sweep_unpaid_applications
    other_applications = BatchApplication.where.not(application_round: @application_round)
    unpaid_applications = other_applications.joins(:application_stage).where('application_stages.number < ?', coding_stage.number)
    count_for_email 'Applications before coding stage' => unpaid_applications.count
    unpaid_applications.each { |application| application.update!(application_round: @application_round, swept_in_at: Time.now) }
  end

  def sweep_from_rounds(round_ids)
    sweep_results = round_ids.each_with_object({}) do |round_id, results|
      source_round = ApplicationRound.find(round_id)
      expired, ignored, rejected = sweep_from_round(source_round)
      results["From #{source_round.display_name}"] = { 'Rejected swept' => rejected, 'Expired swept' => expired, 'Ignored' => ignored }
    end

    count_for_email sweep_results
  end

  def coding_stage
    @coding_stage ||= ApplicationStage.coding_stage
  end

  def sweep_from_round(source_round)
    rejected = 0
    expired = 0
    ignored = 0

    source_round.batch_applications.each do |batch_application|
      if batch_application.swept_at.present? || batch_application.application_stage.number < coding_stage.number
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
      @application_round,
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
      application_round: @application_round,
      team_lead: batch_application.team_lead,
      application_stage: new_application_stage,
      college: batch_application.college,
      team_size: batch_application.team_size,
      swept_in_at: Time.now
    )

    new_application.batch_applicants << batch_application.team_lead

    batch_application.update!(swept_at: Time.now)

    if @skip_payment
      BatchApplicantMailer.swept_skip_payment(batch_application).deliver_later
    else
      BatchApplicantMailer.swept(batch_application).deliver_later
    end
  end

  def new_application_stage
    @skip_payment ? ApplicationStage.coding_stage : ApplicationStage.initial_stage
  end
end
