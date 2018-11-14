require 'rails_helper'

RSpec.describe TimelineEvent, type: :model do
  subject { create :timeline_event }

  describe '#verify!' do
    it 'converts event to a verified timeline event' do
      subject.verify!
      subject.reload
      expect(subject.status).to eq(TimelineEvent::STATUS_VERIFIED)
      expect(subject.status_updated_at).to be_present
    end

    context 'when timeline event has an attachment' do
      let(:timeline_event_file) { create :timeline_event_file }

      subject { create :timeline_event, timeline_event_files: [timeline_event_file] }

      before do
        subject.verify!
      end
    end
  end
end
