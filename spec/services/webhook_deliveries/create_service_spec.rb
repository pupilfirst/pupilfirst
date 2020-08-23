require 'rails_helper'

describe WebhookDeliveries::CreateService do
  subject { described_class.new(course, event_type) }
  let(:course) { create :course }
  let(:event_type) { WebhookDelivery.events[:submission_created] }
  let(:submission) { create :timeline_event }

  describe '#execute' do
    it 'does nothing when the when the course does not have a webhook endpoint' do
      expect { subject.execute(submission) }.not_to change(WebhookDelivery.count)
    end

    context 'When the course has a valid webhook endpoint' do
      let!(:webhook_endpoint) { create :webhook_endpoint, course: course }

      it 'Schedules the webhook delivery job' do
        stub_request(:post, webhook_endpoint.webhook_url).to_return(body: '')

        expect { subject.execute(submission) }.to change { WebhookDelivery.count }.by(1)
      end
    end

    context 'When the course has an inactive webhook endpoint' do
      let!(:webhook_endpoint) { create :webhook_endpoint, course: course, active: false }

      it 'does nothing' do
        expect { subject.execute(submission) }.not_to change(WebhookDelivery.count)
      end
    end

    context 'When the event type in not included in the webhook endpoint' do
      let!(:webhook_endpoint) { create :webhook_endpoint, course: course, events: [] }

      it 'does nothing' do
        expect { subject.execute(submission) }.not_to change(WebhookDelivery.count)
      end
    end
  end
end
