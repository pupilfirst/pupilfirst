require 'rails_helper'

describe Instamojo::DisablePaymentRequestService do
  subject { described_class.new(payment) }

  describe '#disable' do
    context 'when the payment is still in request state' do
      let(:payment) { create :payment, :requested }

      it 'returns the payment without any modifications' do
        # Stub the request to disable payment request.
        stub_request(:post, "https://www.example.com/payment-requests/#{payment.instamojo_payment_request_id}/disable/")
          .with(headers: { 'X-Api-Key': 'API_KEY', 'X-Auth-Token': 'AUTH_TOKEN' })
          .to_return(body: { success: true }.to_json)

        return_value = subject.disable

        # All related columns should have been cleared.
        expect(payment.amount).to eq(nil)
        expect(payment.instamojo_payment_request_id).to eq(nil)
        expect(payment.instamojo_payment_request_status).to eq(nil)
        expect(payment.short_url).to eq(nil)
        expect(payment.long_url).to eq(nil)

        # It should return the updated payment.
        expect(return_value).to eq(payment)
      end
    end

    context 'when the payment is not in requested state anymore' do
      let(:payment) { create :payment, :paid }

      it 'raises custom exception' do
        expect { subject.disable }.to raise_error(Instamojo::NotPendingPaymentException)
      end
    end
  end
end
