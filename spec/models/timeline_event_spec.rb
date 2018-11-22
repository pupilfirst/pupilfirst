require 'rails_helper'

RSpec.describe TimelineEvent, type: :model, broken: true do
  subject { create :timeline_event }

  describe '#verify!' do
    it 'converts event to a verified timeline event' do
      subject.verify!
      subject.reload
      expect(subject.status).to eq(TimelineEvent::STATUS_VERIFIED)
      expect(subject.status_updated_at).to be_present
    end
  end
end
