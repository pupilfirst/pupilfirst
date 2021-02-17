require 'rails_helper'

describe Developers::EventPublisher do
  subject { described_class.new }
  let(:event_type) { 'any-given-event' }
  let(:actor) { double(:actor, id: 234) }
  let(:resource) { double(:resource, id: 456) }

  it 'works' do
    events = []

    ActiveSupport::Notifications.subscribe('any-given-event.pupilfirst') do |*args|
      events << ActiveSupport::Notifications::Event.new(*args)
    end

    subject.execute(event_type, actor, resource)

    expect(events.map(&:payload)).to eq [{
      resource_id: resource.id,
      actor_id: actor.id,
    }]

    ActiveSupport::Notifications.unsubscribe('any-given-event.pupilfirst')
  end
end
