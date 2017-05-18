module Admissions
  class PostPaymentService
    def initialize(payment: nil, founder: nil)
      @payment = payment
      @startup = payment&.startup || founder.startup
      @founder = payment&.founder || founder
    end

    def execute
      # Log payment time, if unrecorded.
      @payment.update!(paid_at: Time.now) if @payment && @payment.paid_at.blank?

      # handle coupons
      perform_coupon_tasks

      # mark the payment target complete
      Admissions::CompleteTargetService.new(@founder, Target::KEY_ADMISSIONS_FEE_PAYMENT).execute

      # IntercomLastApplicantEventUpdateJob.perform_later(@founder, 'payment_complete') unless Rails.env.test?
      Intercom::LevelZeroStageUpdateJob.perform_later(founder, 'Payment Completed') unless Rails.env.test?
    end

    private

    def perform_coupon_tasks
      # mark the coupon applied, if any, as redeemed
      @startup.latest_coupon.mark_redeemed!(@startup) if @startup.latest_coupon.present?

      # create a referral coupon for the current applicant
      @founder.generate_referral_coupon! if @founder.referral_coupon.blank?

      # initiate referral refund if current applicant was referred by someone
      Founders::ReferralRewardService.new(@founder).execute if @startup.referrer.present?
    end
  end
end
