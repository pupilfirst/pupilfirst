require 'rails_helper'

describe CouponUsages::RedeemService do
  subject { described_class.new(coupon_usage, payment) }
  let!(:coupon_usage) { create :coupon_usage }
  let!(:payment) { create :payment, :paid }
  let(:mock_reward_service) { instance_double(CouponUsages::ReferralRewardService) }

  describe '#execute' do
    it 'marks coupon redeemed and awards applicable extensions' do
      expect(coupon_usage.redeemed_at).to eq(nil)
      payment_end_date = payment.billing_end_at

      # The ReferralRewardService will be called.
      expect(CouponUsages::ReferralRewardService).to receive(:new).with(coupon_usage).and_return(mock_reward_service)
      expect(mock_reward_service).to receive(:execute)

      subject.execute

      # The coupon usage must now be marked redeemed.
      expect(coupon_usage.reload.redeemed_at).to_not eq(nil)
      # The payment end date must now be extended by 15 days.
      new_payment_end_date = payment.reload.billing_end_at.beginning_of_minute
      expect(new_payment_end_date).to eq((payment_end_date + 15.days).beginning_of_minute)
    end
  end
end
