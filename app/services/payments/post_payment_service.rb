module Payments
  class PostPaymentService
    def initialize(payment)
      @payment = payment
    end

    def execute
      raise 'PostPaymentService was called for an unpaid payment!' unless @payment.paid?

      Payment.transaction do
        # If payment doesn't have a billing_start_at, set it to 'now'.
        @payment.billing_start_at = Time.zone.now if @payment.billing_start_at.blank?

        # Add 1 month to billing start time to get billing end time.
        @payment.billing_end_at = @payment.billing_start_at + 1.month

        @payment.save!
      end

      invite_founders_to_slack
    end

    private

    def invite_founders_to_slack
      # This is not applicable to founders in level 0. They are yet to link their Slack account.
      return if startup.level_zero?

      # Invite founder back to all channels on Slack.
      startup.founders.not_exited.each do |founder|
        Founders::InviteToSlackChannelsJob.perform_later(founder) if founder.slack_user_id.present?
      end
    end

    def startup
      @startup ||= @payment.startup
    end
  end
end
