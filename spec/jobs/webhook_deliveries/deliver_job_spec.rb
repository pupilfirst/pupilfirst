require 'rails_helper'

describe WebhookDeliveries::DeliverJob do
  subject { described_class }

  let(:course) { create :course }
  let(:event_type) { WebhookDelivery.events[:submission_created] }
  let(:submission) { create :timeline_event }
  let!(:webhook_endpoint) { create :webhook_endpoint, course: course }

  let(:payload) do
    {
      data: TimelineEvents::CreateWebhookDataService.new(submission).data,
      event: event_type
    }.to_json
  end

  let(:response_headers) { { 'header' => ['Header-Value'] } }
  let(:response_body) { Faker::Lorem.word }

  describe '#perform' do
    it 'delivers the data for valid events as an authenticated request' do
      expected_hmac = OpenSSL::HMAC.hexdigest('SHA256', webhook_endpoint.hmac_key, payload)

      stub_request(:post, webhook_endpoint.webhook_url).with(
        body: payload,
        headers: { Authorization: "PF-HMAC-SHA256 #{expected_hmac}" }
      ).to_return(headers: response_headers, body: response_body, status: :ok)

      expect { subject.perform_now(event_type, course, submission) }.to change { WebhookDelivery.count }.by(1)

      last_delivery = WebhookDelivery.last
      expect(last_delivery.webhook_url).to eq(webhook_endpoint.webhook_url)
      expect(last_delivery.response_headers).to eq(response_headers)
      expect(last_delivery.response_body).to eq(response_body)
      expect(last_delivery.payload['data']['id']).to eq(submission.id)
      expect(last_delivery.payload['event']).to eq(event_type)
      expect(last_delivery.course_id).to eq(course.id)
    end

    it 'record the error class when the request fails' do
      stub_request(:post, webhook_endpoint.webhook_url).with(body: payload).to_timeout

      expect { subject.perform_now(event_type, course, submission) }.to change { WebhookDelivery.count }.by(1)

      last_delivery = WebhookDelivery.last
      expect(last_delivery.error_class).to eq("Net::OpenTimeout")
      expect(last_delivery.webhook_url).to eq(webhook_endpoint.webhook_url)
      expect(last_delivery.payload['data']['id']).to eq(submission.id)
      expect(last_delivery.payload['event']).to eq(event_type)
      expect(last_delivery.course_id).to eq(course.id)
    end

    context 'for invalid events' do
      let!(:event_type) { Faker::Lorem.word }

      it 'will not deliver the event' do
        expect { subject.perform_now(event_type, course, submission) }.to raise_error("Unknown webhook event type: #{event_type}")
      end
    end
  end
end

