module Payments
  class PostAdmissionService
    def initialize(payment, founder: nil)
      @payment = payment
      @startup = payment&.startup || founder.startup
      @founder = payment&.founder || founder
    end

    def execute
      # skip if the fee target is already completed
      fee_target = Target.find_by(key: Target::KEY_ADMISSIONS_FEE_PAYMENT)
      return if fee_target.status(@founder) == Targets::StatusService::STATUS_COMPLETE

      # ensure the subscription window starts from time of payment
      Payments::PostPaymentService.new(@payment).execute

      # Create a referral coupon for the startup.
      Coupons::CreateService.new.generate_referral(@startup) if @startup.referral_coupon.blank?

      # handle coupon usage
      CouponUsages::RedeemService.new(@startup.coupon_usage, @payment).execute if @startup.applied_coupon.present?

      # mark the payment target complete
      Admissions::CompleteTargetService.new(@founder, Target::KEY_ADMISSIONS_FEE_PAYMENT).execute

      # Fix the current Founder::FEE as the perpetual undiscounted_founder_fee for this startup.
      @startup.update!(undiscounted_founder_fee: Founder::FEE) if @startup.undiscounted_founder_fee.blank?

      # IntercomLastApplicantEventUpdateJob.perform_later(@founder, 'payment_complete') unless Rails.env.test?
      Intercom::LevelZeroStageUpdateJob.perform_later(@founder, 'Payment Completed')

      # Send a notification to #memberships channel on our private Slack.
      PrivateSlack::PaymentNotificationJob.perform_later(@founder)
    end
  end
end
