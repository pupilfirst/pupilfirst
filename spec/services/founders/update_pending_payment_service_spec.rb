require 'rails_helper'

describe Founders::UpdatePendingPaymentService do
  subject { described_class.new(founder, period) }

  let(:startup) { create :startup }
  let(:founder) { startup.team_lead }
  let(:period) { [1, 3, 6].sample }
  let(:request_payment_service) { instance_double(Instamojo::RequestPaymentService) }
  let(:verify_payment_request_service) { instance_double(Instamojo::VerifyPaymentRequestService) }
  let(:disable_payment_request_service) { instance_double(Instamojo::DisablePaymentRequestService) }
  let(:updated_payment) { double 'Payment' }
  let(:disabled_payment) { double 'Disabled payment' }

  before do
    startup.payments << payment
    startup.save!
  end

  describe '#update' do
    context 'when the pending payment is in requested state' do
      let(:startup) { create :startup, :subscription_active }
      let(:payment) { create :payment, :requested }

      context 'when the payment period is unchanged' do
        let(:period) { payment.period }

        it 'verifies and returns payment' do
          allow(Instamojo::VerifyPaymentRequestService).to receive(:new).with(payment, period).and_return(verify_payment_request_service)
          allow(verify_payment_request_service).to receive(:verify).and_return(updated_payment)

          expect(subject.update).to eq(updated_payment)
        end
      end

      context 'when the payment period has changed' do
        let(:period) { 3 }

        it 'rebuilds payment' do
          allow(Instamojo::DisablePaymentRequestService).to receive(:new).and_return(disable_payment_request_service)
          allow(disable_payment_request_service).to receive(:disable).and_return(disabled_payment)
          allow(Instamojo::RequestPaymentService).to receive(:new).with(disabled_payment, period).and_return(request_payment_service)
          allow(request_payment_service).to receive(:request).and_return(updated_payment)

          expect(subject.update).to eq(updated_payment)
        end
      end
    end

    context 'when the pending payment is fresh' do
      let(:payment) { create :payment }

      it 'creates new Instamojo payment request' do
        allow(Instamojo::RequestPaymentService).to receive(:new).with(payment, period).and_return(request_payment_service)
        allow(request_payment_service).to receive(:request).and_return(updated_payment)

        expect(subject.update).to eq(updated_payment)
      end
    end
  end
end
