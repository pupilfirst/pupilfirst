module Admissions
  class PostPaymentService
    def initialize(payment:, founder: nil)
      @payment = payment
      @startup = payment&.startup || founder.startup
      @founder = payment&.founder || founder
    end

    def execute
      # skip if the fee target is already completed
      fee_target = Target.find_by(key: Target::KEY_ADMISSIONS_FEE_PAYMENT)
      return if fee_target.status(@founder) == Targets::StatusService::STATUS_COMPLETE

      # ensure the subscription window starts from time of payment
      Founders::PostPaymentService.new(@payment).execute

      # handle coupons
      perform_coupon_tasks

      # mark the payment target complete
      Admissions::CompleteTargetService.new(@founder, Target::KEY_ADMISSIONS_FEE_PAYMENT).execute

      # IntercomLastApplicantEventUpdateJob.perform_later(@founder, 'payment_complete') unless Rails.env.test?
      Intercom::LevelZeroStageUpdateJob.perform_later(@founder, 'Payment Completed')
    end

    private

    def applied_coupon
      @applied_coupon ||= @startup.latest_coupon
    end

    def perform_coupon_tasks
      # create a referral coupon for the current applicant
      @founder.generate_referral_coupon! if @founder.referral_coupon.blank?

      if applied_coupon.present?
        # mark the coupon applied as redeemed
        applied_coupon.mark_redeemed!(@startup)

        # Award the user the applicable extension
        @payment.update!(billing_end_at: @payment.billing_end_at + applied_coupon.user_extension_days.days)

        # initiate referral refund if current applicant was referred by someone
        Founders::ReferralRewardService.new(applied_coupon).execute
      end
    end
  end
end
