require 'rails_helper'

describe Instamojo do
  before :all do
    APP_CONFIG[:instamojo] = {
      url: 'https://www.example.com',
      api_key: 'API_KEY',
      auth_token: 'AUTH_TOKEN'
    }
  end

  after :all do
    APP_CONFIG[:instamojo] = {
      url: ENV['INSTAMOJO_API_URL'],
      api_key: ENV['INSTAMOJO_API_KEY'],
      auth_token: ENV['INSTAMOJO_AUTH_TOKEN']
    }
  end

  describe '#create_payment_request' do
    let(:amount) { rand(10_000) }
    let(:buyer_name) { Faker::Name.name }
    let(:email) { Faker::Internet.email(buyer_name) }

    before :each do
      stub_request(:post, 'https://www.example.com/payment-requests/')
        .with(
          body: {
            allow_repeated_payments: 'false',
            amount: amount.to_s,
            buyer_name: buyer_name,
            email: email,
            purpose: 'Application to SV.CO',
            redirect_url: 'http://localhost:3000/instamojo/redirect',
            send_email: 'false',
            send_sms: 'false'
          },
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/x-www-form-urlencoded',
            'Host' => 'www.example.com',
            'User-Agent' => 'Ruby',
            'X-Api-Key' => 'API_KEY',
            'X-Auth-Token' => 'AUTH_TOKEN'
          }
        )
        .to_return(
          body: {
            payment_request: {
              id: 'd66cb29dd059482e8072999f995c4eef',
              phone: '+919999999999',
              email: 'foo@example.com',
              buyer_name: 'John Doe',
              amount: amount.to_s,
              purpose: 'Application to SV.CO',
              status: 'Pending',
              send_sms: true,
              send_email: true,
              sms_status: 'Pending',
              email_status: 'Pending',
              longurl: 'https://www.instamojo.com/@ashwch/d66cb29dd059482e8072999f995c4eef/',
              redirect_url: 'http://localhost:3000/instamojo/redirect',
              created_at: '2015-10-07T21:36:34.665Z',
              modified_at: '2015-10-07T21:36:34.665Z',
              allow_repeated_payments: false
            },
            success: true
          }.to_json
        )
    end

    it 'creates a payment request and returns basic details' do
      response = subject.create_payment_request(amount: amount, buyer_name: buyer_name, email: email)

      expect(response).to eq(
        id: 'd66cb29dd059482e8072999f995c4eef',
        status: 'Pending',
        short_url: nil,
        long_url: 'https://www.instamojo.com/@ashwch/d66cb29dd059482e8072999f995c4eef/'
      )
    end
  end

  describe '#payment_details' do
    let(:payment_request_id) { 'd66cb29dd059482e8072999f995c4eef' }
    let(:payment_id) { 'MOJO6622005J18010210' }

    before :each do
      stub_request(:get, "https://www.example.com/payment-requests/#{payment_request_id}/#{payment_id}/")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'www.example.com',
            'User-Agent' => 'Ruby',
            'X-Api-Key' => 'API_KEY',
            'X-Auth-Token' => 'AUTH_TOKEN' }
        )
        .to_return(
          body: {
            payment_request: {
              id: payment_request_id,
              phone: nil,
              email: 'foo@example.com',
              buyer_name: 'John Doe',
              amount: '2500.00',
              purpose: 'FIFA 16',
              status: 'Completed',
              send_sms: true,
              send_email: true,
              sms_status: 'Pending',
              email_status: 'Pending',
              shorturl: 'https://imjo.in/NNxHg',
              longurl: 'https://www.instamojo.com/@ashwch/d66cb29dd059482e8072999f995c4eef',
              redirect_url: 'http://www.example.com/redirect/',
              webhook: 'http://www.example.com/webhook/',
              payment: {
                payment_id: payment_id,
                quantity: 1,
                status: 'Credit',
                link_slug: nil,
                link_title: nil,
                buyer_name: 'John Doe',
                buyer_phone: '+919999999999',
                buyer_email: 'foo@example.com',
                currency: 'INR',
                unit_price: '2500.00',
                amount: '2500.00',
                fees: '125.00',
                shipping_address: nil,
                shipping_city: nil,
                shipping_state: nil,
                shipping_zip: nil,
                shipping_country: nil,
                discount_code: nil,
                discount_amount_off: nil,
                variants: [],
                custom_fields: {},
                affiliate_id: nil,
                affiliate_commission: '0',
                created_at: '2015-12-27T21:01:51.879Z'
              },
              created_at: '2015-10-07T21:36:34.665Z',
              modified_at: '2015-10-07T21:36:34.665Z',
              allow_repeated_payments: false
            },
            success: true
          }.to_json
        )
    end

    it 'returns details of payment and request' do
      response = subject.payment_details(payment_request_id: payment_request_id, payment_id: payment_id)

      expect(response).to eq(
        payment_request_status: 'Completed',
        payment_status: 'Credit',
        fees: '125.00'
      )
    end
  end

  describe 'payment_request_details' do
    let(:payment_request_id) { 'd66cb29dd059482e8072999f995c4eef' }

    before :each do
      stub_request(:get, "https://www.example.com/payment-requests/#{payment_request_id}/")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'www.example.com',
            'User-Agent' => 'Ruby',
            'X-Api-Key' => 'API_KEY',
            'X-Auth-Token' =>
              'AUTH_TOKEN' }
        )
        .to_return(
          body: {
            payment_request: {
              id: payment_request_id,
              phone: '+919999999999',
              email: 'foo@example.com',
              buyer_name: 'John Doe',
              amount: '2500.00',
              purpose: 'FIFA 16',
              status: 'Sent',
              send_sms: true,
              send_email: true,
              sms_status: 'Pending',
              email_status: 'Sent',
              shorturl: 'https://imjo.in/NNxHg',
              longurl: 'https://www.instamojo.com/@ashwini/d66cb29dd059482e8072999f995c4eef',
              redirect_url: 'http://www.example.com/redirect/',
              webhook: 'http://www.example.com/webhook/',
              payments: [],
              created_at: '2015-10-07T21:36:34.665Z',
              modified_at: '2015-10-07T21:36:37.572Z',
              allow_repeated_payments: false
            },
            success: true
          }.to_json
        )
    end

    it 'returns details of payment request' do
      response = subject.payment_request_details(payment_request_id: payment_request_id)

      expect(response).to eq(
        payment_request_status: 'Sent',
        short_url: 'https://imjo.in/NNxHg',
        redirect_url: 'http://www.example.com/redirect/',
        webhook_url: 'http://www.example.com/webhook/'
      )
    end
  end
end
