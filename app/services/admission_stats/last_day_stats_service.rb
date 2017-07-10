module AdmissionStats
  class LastDayStatsService
    def load
      {
        'Signed Up' => signed_up,
        'Screening Completed' => screening_completed,
        'Fee Paid' => fee_paid,
        'Payment Initiated' => payment_initiated
      }
    end

    private

    def signed_up
      Startup.level_zero.where(created_at: yesterday).count
    end

    def screening_completed
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_ADMISSIONS_SCREENING }).where(created_at: yesterday).count
    end

    def fee_paid
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_ADMISSIONS_FEE_PAYMENT }).where(created_at: yesterday).count
    end

    def payment_initiated
      Startup.level_zero.joins(:payment).merge(Payment.requested).where(payments: { created_at: yesterday }).count
    end

    def yesterday
      1.day.ago.beginning_of_day..1.day.ago.end_of_day
    end

    def verified_timeline_events
      TimelineEvent.where(status: TimelineEvent::STATUS_VERIFIED)
    end
  end
end
