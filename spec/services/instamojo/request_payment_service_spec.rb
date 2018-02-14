require 'rails_helper'

describe Instamojo::RequestPaymentService do
  subject { described_class.new(payment) }

  let(:instamojo) { instance_double Instamojo }
  let(:payment) { create :payment }
  let(:startup) { payment.startup }
  let(:founder) { payment.founder }
  let(:short_url) { Faker::Internet.url }
  let(:long_url) { Faker::Internet.url }

  before do
    allow(Instamojo).to receive(:new).and_return(instamojo)
  end

  describe '#request' do
    it 'creates a new instamojo payment request and returns updated payment' do
      amount = Startups::FeeAndCouponDataService.new(startup).emi

      expect(instamojo).to receive(:create_payment_request)
        .with(
          amount: amount,
          buyer_name: founder.name,
          email: founder.email
        )
        .and_return(
          id: 'PAYMENT_REQUEST_ID',
          status: Instamojo::PAYMENT_REQUEST_STATUS_PENDING,
          short_url: short_url,
          long_url: long_url
        )

      return_value = subject.request

      # It should set new Instamojo payment request values.
      expect(payment.reload.instamojo_payment_request_id).to eq('PAYMENT_REQUEST_ID')
      expect(payment.instamojo_payment_request_status).to eq(Instamojo::PAYMENT_REQUEST_STATUS_PENDING)
      expect(payment.short_url).to eq(short_url)
      expect(payment.long_url).to eq(long_url)

      # It should return the updated payment.
      expect(return_value).to eq(payment)
    end
  end
end
