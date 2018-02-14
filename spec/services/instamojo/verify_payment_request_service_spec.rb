require 'rails_helper'

describe Instamojo::VerifyPaymentRequestService do
  subject { described_class.new(payment) }

  let(:instamojo) { instance_double Instamojo }
  let(:payment) { create :payment }

  before do
    allow(Instamojo).to receive(:new).and_return(instamojo)
  end

  describe '#verify' do
    context 'when the payment is still valid' do
      it 'returns the payment without any modifications' do
        expect(instamojo).to receive(:payment_request_details)
          .with(payment_request_id: payment.instamojo_payment_request_id)
          .and_return(payment_request_status: 'Pending')

        expect(Instamojo::RequestPaymentService).not_to receive(:new)
        expect(subject.verify).to eq(payment)
      end
    end

    context 'when the payment is not valid anymore' do
      let(:request_payment_service) { instance_double Instamojo::RequestPaymentService }
      let(:updated_payment) { double 'Updated Payment' }

      before do
        allow(instamojo).to receive(:payment_request_details).and_return(payment_request_status: 'Failed')
      end

      it 'recreates the payment request and returns updated payment' do
        expect(Instamojo::RequestPaymentService).to receive(:new).with(payment).and_return(request_payment_service)
        expect(request_payment_service).to receive(:request).and_return(updated_payment)
        expect(subject.verify).to eq(updated_payment)
      end
    end
  end
end
