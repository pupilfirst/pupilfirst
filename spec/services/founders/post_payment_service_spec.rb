require 'rails_helper'

describe Founders::PostPaymentService do
  subject { described_class.new(payment) }

  describe '#execute' do
    context 'when billing start date for the payment has passed' do
      let(:payment) { create :payment, :paid, billing_start_at: 10.days.ago }
      let(:mock_invite_service) { instance_double Founders::InviteToSlackChannelsService }

      it 'updates the billing dates for payment and invites the founders back to Slack' do
        founder_count = payment.startup.founders.count
        expect(Founders::InviteToSlackChannelsService).to receive(:new).exactly(founder_count).times.and_return(mock_invite_service)
        expect(mock_invite_service).to receive(:execute).exactly(founder_count).times
        expect do
          subject.execute
        end.to(change { payment.reload.billing_start_at }.and(change { payment.reload.billing_end_at }))
      end
    end

    context 'when the billing start date for the payment is in the future' do
      let(:payment) { create :payment, :paid, billing_start_at: 2.days.from_now }

      it 'does nothing' do
        expect do
          subject.execute
        end.to(not_change { payment.reload.billing_start_at }.and(change { payment.reload.billing_end_at }))
      end
    end

    context 'when period is more than 1 month' do
      let(:billing_start_at) { 2.days.from_now }
      let(:payment) { create :payment, :paid, billing_start_at: billing_start_at, period: 3 }

      it 'sets billing_end_at the specified number of months away' do
        subject.execute
        expect(payment.reload.billing_end_at.to_date - billing_start_at.to_date).to be_between(28 * 3, 31 * 3).exclusive
      end
    end

    context 'when there are pending referral reward days' do
      let(:billing_start_at) { 2.days.from_now }
      let(:payment) { create :payment, :paid, billing_start_at: billing_start_at }
      let(:startup) { payment.startup }

      before do
        startup.update!(referral_reward_days: 10)
      end

      it 'adds reward days to billing_end_at' do
        subject.execute
        expect(payment.reload.billing_end_at.to_date - billing_start_at.to_date).to be_between(38, 41).inclusive
      end

      it 'clears reward days after assigning it to payment' do
        expect { subject.execute }.to(change { startup.reload.referral_reward_days })
        expect(startup.referral_reward_days).to eq(0)
      end
    end

    context 'when the payment is unpaid' do
      let(:payment) { create :payment }

      it 'raises an error' do
        expect { subject.execute }.to raise_error('PostPaymentService was called for an unpaid payment!')
      end
    end
  end
end
