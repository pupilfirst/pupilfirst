module AdmissionStats
  class FunnelStatsService
    # @param start_time [DateTime, String] (Optional) Default to beginning of yesterday.
    # @param end_time [DateTime, String] (Optional) Defaults to end of yesterday.
    def initialize(start_time = nil, end_time = nil)
      start_time ||= 1.day.ago.beginning_of_day
      end_time ||= 1.day.ago.end_of_day
      start_time = Date.parse(start_time).beginning_of_day if start_time.is_a?(String)
      end_time = Date.parse(end_time).end_of_day if end_time.is_a?(String)
      @date_range = start_time..end_time
    end

    def load
      {
        'Total Sign Ups' => signed_up,
        'Self Evaluation Completed' => self_evaluation_completed,
        'Round 1 Task Passed' => round_one_task_passed,
        'Round 2 Task Passed' => round_two_task_passed,
        'Passed Interview' => interview_passed,
        'Payment Initiated' => payment_initiated,
        'Fee Paid Teams' => fee_paid_teams.count,
        'Revenue' => "₹#{revenue.to_i}"
      }
    end

    private

    def signed_up
      Startup.level_zero.where(created_at: @date_range).count
    end

    def self_evaluation_completed
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_SCREENING }).where(created_at: @date_range).count
    end

    def round_one_task_passed
      verified_timeline_events.joins(:target).where(targets: { key: [Target::KEY_R1_TASK, Target::KEY_R1_SHOW_PREVIOUS_WORK] }).where(created_at: @date_range).count
    end

    def round_two_task_passed
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_R2_TASK }).where(created_at: @date_range).count
    end

    def interview_passed
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_ATTEND_INTERVIEW }).where(created_at: @date_range).count
    end

    def fee_paid_teams
      @fee_paid_startups ||= verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_FEE_PAYMENT }).where(created_at: @date_range).pluck(:startup_id)
    end

    def revenue
      Payment.where(paid_at: @date_range).sum(:amount)
    end

    def payment_initiated
      Startup.joins(:payments).where(payments: { created_at: @date_range }).where.not(payments: { instamojo_payment_request_id: nil }).count
    end

    def verified_timeline_events
      @verified_timeline_events ||= TimelineEvent.where(status: TimelineEvent::STATUS_VERIFIED)
    end
  end
end
