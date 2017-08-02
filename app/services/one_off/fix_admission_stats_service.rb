module OneOff
  class FixAdmissionStatsService
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def execute
      time = Time.parse('May 8, 2017 00:00:00 +0530')

      # Move 2 teams who paid, but haven't added cofounders to 'Admitted' stage.
      fee_paid_stage = Startup::ADMISSION_STAGE_FEE_PAID
      startups_at_fee_paid_stage = Startup.where(admission_stage: fee_paid_stage)
      startups_completed_target = startups_at_fee_paid_stage.joins(timeline_events: :target).where(timeline_events: { status: TimelineEvent::STATUS_VERIFIED }, targets: { key: Target::KEY_ADMISSIONS_COFOUNDER_ADDITION })

      to_be_moved = startups_at_fee_paid_stage.pluck(:id) - startups_completed_target.pluck(:id)

      to_be_moved.each do |startup_id|
        Startup.find(startup_id).update!(admission_stage: Startup::ADMISSION_STAGE_ADMITTED)
      end

      # Remove double entries for fee paid for a single startup, because of some bug that was present in the past.
      target = Target.find_by(key: Target::KEY_ADMISSIONS_FEE_PAYMENT)
      startup_ids = Startup.joins(timeline_events: :target).where(timeline_events: { target: target }).pluck('startups.id')
      unique_ids = startup_ids.uniq

      # Remove each unique ID from startup_ids array only once, to leave startups with duplicates.
      unique_ids.each { |id| startup_ids.slice!(startup_ids.index(id)) }

      startup_ids.each do |startup_id|
        Startup.find(startup_id).timeline_events.joins(:target).where(target: target).order('timeline_events.created_at DESC').first.destroy
      end

      # Move 16 teams who registered and attempted payment as per old flow, but didn't add cofounders, to 'Screening Done'
      # stage.
      payment_initiated_stage = Startup::ADMISSION_STAGE_PAYMENT_INITIATED
      cofounder_target = Target.find_by(key: Target::KEY_ADMISSIONS_COFOUNDER_ADDITION)
      startups_at_payment_initiated_stage = Startup.where(admission_stage: payment_initiated_stage)
      startups_completed_cofounder_target = startups_at_payment_initiated_stage.includes(timeline_events: :target).where(timeline_events: { target: cofounder_target })

      to_be_moved = startups_at_payment_initiated_stage.pluck(:id) - startups_completed_cofounder_target.pluck(:id)

      to_be_moved.each do |startup_id|
        Startup.find(startup_id).update!(admission_stage: Startup::ADMISSION_STAGE_SCREENING_COMPLETED)
      end

      # Move payments for old startups from Batch 1 / 2 / 3 to pre August 8 - so that they're not accounted in current stats.
      Payment.joins(:startup).where('startups.created_at < ?', time).update(created_at: time - 1.day, paid_at: time - 1.day)

      # Delete payment entries for startups in level 0, who initiated payment without adding cofounders (pre-subscription)
      # There is a possible issue here - if any of these startups make payment using old links (sent via email), they'll
      # have to be refunded manually.
      startups_with_unpaid_payment = Startup.joins(:payments).merge(Payment.pending).where('startups.created_at > ?', time)

      startups_with_unpaid_payment.each do |startup|
        unless cofounder_target.status(startup.admin) == Targets::StatusService::STATUS_COMPLETE
          raise if startup.payments.count > 1 || startup.payments.first.paid?
          startup.payments.first.destroy
        end
      end

      nil
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
