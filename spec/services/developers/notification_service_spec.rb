require 'rails_helper'

describe Developers::NotificationService do
  subject { described_class.new(webhook_service: webhook_service) }
  let(:context_) { Object.new }
  let(:event_type) { 'any-given-event' }
  let(:actor) { Object.new }
  let(:resource) { Object.new }
  let(:webhook_service) { instance_double('WebhookDeliveries::CreateService') }

  it 'pass the call to WebhookDeliveries::CreateService' do
    expect(webhook_service).to receive(:execute).with(context_, event_type, resource).once
    subject.execute(context_, event_type, actor, resource)
  end
end
