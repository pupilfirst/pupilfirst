require 'rails_helper'

RSpec.describe TimelineEventFile, type: :model do
  describe '#visible_to?' do
    subject { create :timeline_event_file }

    context 'when file is public' do
      it 'returns true' do
        expect(subject.visible_to?(nil)).to eq(true)
      end
    end

    context 'when file is private' do
      subject { create :timeline_event_file, private: true }

      context 'when user is creator of timeline event' do
        it 'returns true' do
          expect(subject.visible_to?(subject.timeline_event.user)).to eq(true)
        end
      end

      context 'when user is founder of linked startup' do
        it 'returns true' do
          expect(subject.visible_to?(subject.timeline_event.startup.founders.last)).to eq(true)
        end
      end

      context 'when user is neither creator nor founder' do
        let(:another_user) { create :user_with_out_password }

        it 'returns false' do
          expect(subject.visible_to?(nil)).to eq(false)
          expect(subject.visible_to?(another_user)).to eq(false)
        end
      end
    end
  end
end
