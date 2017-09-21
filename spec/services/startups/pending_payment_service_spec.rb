require 'rails_helper'

describe Startups::PendingPaymentService do
  subject { described_class.new(startup) }

  let(:startup) { create :startup }

  describe '#fetch' do
    context 'when startup has no pending payment' do
      it 'returns nil' do
        expect(subject.fetch).to eq(nil)
      end
    end

    context 'when startup has a pending payment' do
      let(:startup) { create :level_0_startup }
      let!(:payment) { create :payment, startup: startup }

      it 'returns the pending payment' do
        expect(subject.fetch).to eq(payment)
      end
    end

    context 'when startup has more than one pending payment' do
      let(:startup) { create :startup, :subscription_active }

      before do
        # Create two pending payments.
        create :payment, :requested, startup: startup
        create :payment, startup: startup
      end

      it 'raises an exception' do
        expect { subject.fetch }.to raise_error(Startups::PendingPaymentService::MultiplePendingPaymentsException)
      end
    end
  end
end
