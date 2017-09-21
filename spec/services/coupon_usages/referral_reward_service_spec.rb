require 'rails_helper'

describe CouponUsages::ReferralRewardService do
  subject { described_class.new(coupon_usage) }

  let!(:paid_payment) { create :payment, :paid, startup: referrer_startup }
  let!(:coupon) { create :coupon, referrer_startup: referrer_startup }
  let!(:coupon_usage) { create :coupon_usage, coupon: coupon }

  describe '#execute' do
    context 'when the referrer startup does not have a pending payment' do
      let!(:referrer_startup) { create :startup }
      let!(:paid_payment_end) { paid_payment.billing_end_at }

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
      let!(:referrer_startup) { create :startup, referral_reward_days: 10 }

      before do
        create :payment, :requested, startup: referrer_startup
      end

      it 'adds the referral reward extension to the pending payment' do
        # The current subscription should not have changed, and startup should now have extra referral reward days.
        expect do
          subject.execute
        end.to(not_change { paid_payment.reload.billing_end_at.beginning_of_minute }
          .and((change { referrer_startup.reload.referral_reward_days }).from(10).to(20)))

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
