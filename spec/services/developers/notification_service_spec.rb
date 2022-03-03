require 'rails_helper'

describe Developers::NotificationService do
  subject do
    described_class.new(
      webhook_service: webhook_service,
      event_publisher: event_publisher
    )
  end
  let(:course) { Object.new }
  let(:event_type) { 'any-given-event' }
  let(:actor) { Object.new }
  let(:resource) { Object.new }
  let(:webhook_service) { instance_double('WebhookDeliveries::CreateService') }
  let(:event_publisher) { instance_double('Developers::EventPublisher') }

  it 'pass the call to webhook service & event pubisher' do
    expect(webhook_service).to receive(:execute)
      .with(course, event_type, actor, resource)
      .once
    expect(event_publisher).to receive(:execute)
      .with(event_type, actor, resource)
      .once
    subject.execute(course, event_type, actor, resource)
  end
end
