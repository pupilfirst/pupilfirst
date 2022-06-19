require 'rails_helper'

describe WebhookDeliveries::CreateService do
  subject { described_class.new }
  let(:course) { create :course }
  let(:event_type) { :submission_created }
  let(:submission) { create :timeline_event }
  let(:actor) { create :user }

  around do |example|
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    example.run
    ActiveJob::Base.queue_adapter = original_adapter
  end

  describe '#execute' do
    context 'when supplied event type is invalid' do
      let(:event_type) { :invalid }

      it 'raises exception' do
        expect {
          subject.execute(course, event_type, actor, submission)
        }.to raise_error('Invalid event_type invalid encountered')
      end
    end

    context 'when the course does not have a webhook endpoint' do
      it 'does nothing' do
        subject.execute(course, event_type, actor, submission)
        expect(WebhookDeliveries::DeliverJob).not_to have_been_enqueued
      end
    end

    context 'when the course has an inactive webhook endpoint' do
      let!(:webhook_endpoint) do
        create :webhook_endpoint, course: course, active: false
      end

      it 'does nothing' do
        subject.execute(course, event_type, actor, submission)
        expect(WebhookDeliveries::DeliverJob).not_to have_been_enqueued
      end
    end

    context 'when the event type in not included in the webhook endpoint' do
      let!(:webhook_endpoint) do
        create :webhook_endpoint, course: course, events: []
      end

      it 'does nothing' do
        subject.execute(course, event_type, actor, submission)
        expect(WebhookDeliveries::DeliverJob).not_to have_been_enqueued
      end
    end

    context 'when the webhook endpoint is active, and the event is included' do
      let!(:webhook_endpoint) { create :webhook_endpoint, course: course }

      it 'enqueues a job to deliver the webhook request' do
        subject.execute(course, event_type, actor, submission)
        expect(WebhookDeliveries::DeliverJob).to have_been_enqueued
      end
    end
  end
end
