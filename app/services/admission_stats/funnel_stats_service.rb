module AdmissionStats
  class FunnelStatsService
    def initialize(start_date, end_date)
      start_date = start_date.present? ? Date.parse(start_date).beginning_of_day : 1.day.ago.beginning_of_day
      end_date = end_date.present? ? Date.parse(end_date).end_of_day : 1.day.ago.end_of_day
      @date_range = start_date..end_date
    end

    def load
      {
        'Total Sign Ups' => signed_up,
        'Screening Completed' => screening_completed,
        'Added Cofounders' =>  cofounders_added,
        'Payment Initiated' => payment_initiated,
        'Fee Paid' => fee_paid,
        'Revenue' => "₹#{revenue.to_i}"
      }
    end

    private

    def signed_up
      Startup.level_zero.where(created_at: @date_range).count
    end

    def screening_completed
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_ADMISSIONS_SCREENING }).where(created_at: @date_range).count
    end

    def fee_paid
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_ADMISSIONS_FEE_PAYMENT }).where(created_at: @date_range).count
    end

    def revenue
      Payment.where(paid_at: @date_range).sum(:amount)
    end

    def payment_initiated
      Startup.joins(:payments).where(payments: { created_at: @date_range }).count
    end

    def cofounders_added
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_ADMISSIONS_COFOUNDER_ADDITION }).where(created_at: @date_range).count
    end

    def verified_timeline_events
      @verified_timeline_events ||= TimelineEvent.where(status: TimelineEvent::STATUS_VERIFIED)
    end
  end
end
