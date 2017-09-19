module Founders
  class PostPaymentService
    def initialize(payment)
      @payment = payment
      @startup = payment.startup
    end

    def execute
      raise 'PostPaymentService was called for an unpaid payment!' unless @payment.paid?

      # If payment was made within the active billing period, there is nothing to be done.
      return if @payment.billing_start_at.future?

      # Otherwise, the billing period will have to be updated.
      payment_duration = @payment.billing_end_at - @payment.billing_start_at
      @payment.update!(billing_start_at: Time.zone.now, billing_end_at: Time.zone.now + payment_duration)

      # and the founders invited back to all channels on Slack.
      return if @startup.blank? || @startup.level_zero?
      @startup.founders.not_exited.each { |founder| Founders::InviteToSlackChannelsJob.perform_later(founder) }
    end
  end
end
