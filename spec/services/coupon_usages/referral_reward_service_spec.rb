require 'rails_helper'

describe CouponUsages::ReferralRewardService do
  subject { described_class.new(coupon_usage) }
  let!(:referrer_startup) { create :startup }
  let!(:coupon) { create :coupon, referrer_startup: referrer_startup }
  let!(:coupon_usage) { create :coupon_usage, coupon: coupon }
  let!(:paid_payment) { create :payment, :paid, startup: referrer_startup }
  let!(:pending_payment) { create :payment, :requested }
  let!(:paid_payment_end) { paid_payment.billing_end_at }
  let!(:pending_payment_end) { pending_payment.billing_end_at }

  describe '#execute' do
    context 'when the referrer startup does not have a pending payment' do
      it 'add the referral reward extension to the current subscription' do
        subject.execute

        # The current subscription should have expanded by 10 days.
        new_paid_payment_end = paid_payment.reload.billing_end_at.beginning_of_minute
        expect(new_paid_payment_end).to eq((paid_payment_end + 10.days).beginning_of_minute)

        # The referrer should have received the appropriate mail.
        open_email(referrer_startup.team_lead.email)
        expect(current_email.subject).to include('Your startup has unlocked SV.CO referral rewards!')
        expect(current_email.body).to include('We have extended your current subscription with the reward period.')

        # The coupon usage must be marked as rewarded.
        expect(coupon_usage.reload.rewarded_at).to_not eq(nil)
      end
    end

    context 'when the referrer startup has a pending payment' do
      before do
        # Assign the pending payment to the startup.
        pending_payment.update!(startup: referrer_startup)
      end
      it 'adds the referral reward extension to the pending payment' do
        subject.execute

        # The current subscription should not have changed.
        expect(paid_payment.reload.billing_end_at.beginning_of_minute).to eq(paid_payment_end.beginning_of_minute)

        # The pending payment should have expanded by 10 days.
        new_pending_payment_end = pending_payment.reload.billing_end_at.beginning_of_minute
        expect(new_pending_payment_end).to eq((pending_payment_end + 10.days).beginning_of_minute)

        # The referrer should have received the appropriate mail.
        open_email(referrer_startup.team_lead.email)
        expect(current_email.subject).to include('Your startup has unlocked SV.CO referral rewards!')
        expect(current_email.body).to include('Your subscription will be extended with the reward period upon renewal of your subscription.')

        # The coupon usage must be marked as rewarded.
        expect(coupon_usage.reload.rewarded_at).to_not eq(nil)
      end
    end
  end
end
