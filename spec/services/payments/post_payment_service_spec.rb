require 'rails_helper'

describe Payments::PostPaymentService do
  subject { described_class.new(payment) }

  let(:mock_invite_service) { instance_double Founders::InviteToSlackChannelsService, execute: nil }

  before do
    allow(Founders::InviteToSlackChannelsService).to receive(:new).and_return(mock_invite_service)
  end

  describe '#execute' do
    let(:payment) { create :payment, :paid }

    before do
      # Add slack_user_id to founders.
      payment.startup.founders.each { |founder| founder.update!(slack_user_id: SecureRandom.uuid) }
    end

    it 'invites founders back to Slack' do
      founders_count = payment.startup.founders.count
      expect(Founders::InviteToSlackChannelsService).to receive(:new).exactly(founders_count).times
      expect(mock_invite_service).to receive(:execute).exactly(founders_count).times
      subject.execute
    end

    context 'when billing start date is not set' do
      let(:payment) { create :payment, :paid, billing_start_at: nil }

      it 'updates the billing dates for payment' do
        expect do
          subject.execute
        end.to(change { payment.reload.billing_start_at }.and(change { payment.reload.billing_end_at }))
      end
    end

    context 'when the billing start date for the payment is in the future' do
      let(:payment) { create :payment, :paid, billing_start_at: 2.days.from_now }

      it 'sets only the end time by adding one month to start time' do
        expect do
          subject.execute
        end.to(not_change { payment.reload.billing_start_at }.and(change { payment.reload.billing_end_at }))

        expect(payment.billing_end_at.beginning_of_minute).to eq((payment.billing_start_at + 1.month).beginning_of_minute)
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
