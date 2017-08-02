module AdmissionStats
  class FunnelStatsService
    def initialize(params = {})
      @params = params
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
      Startup.level_zero.where(created_at: date_range).count
    end

    def screening_completed
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_ADMISSIONS_SCREENING }).where(created_at: date_range).count
    end

    def fee_paid
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_ADMISSIONS_FEE_PAYMENT }).where(created_at: date_range).count
    end

    def revenue
      Payment.where(paid_at: date_range).sum(:amount)
    end

    def payment_initiated
      Startup.level_zero.joins(:payments).merge(Payment.requested).where(payments: { created_at: date_range }).count
    end

    def cofounders_added
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_ADMISSIONS_COFOUNDER_ADDITION }).where(created_at: date_range).count
    end

    def yesterday
      1.day.ago.beginning_of_day..1.day.ago.end_of_day
    end

    def verified_timeline_events
      TimelineEvent.where(status: TimelineEvent::STATUS_VERIFIED)
    end

    def date_range
      if @params.include?(:from)
        Date.parse(@params[:from]).beginning_of_day..Date.parse(@params[:to]).end_of_day
      else
        yesterday
      end
    end
  end
end
