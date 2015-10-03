require 'rails_helper'

RSpec.describe Target, type: :model do
  let(:subject) { create :target }

  describe '#status' do
    context 'when timeline_event of supplied type does not exist' do
      it 'returns pending' do
        expect(subject.status).to eq('pending')
      end
    end

    context 'when timeline_event of supplied type exists' do
      let!(:timeline_event) { create :timeline_event, timeline_event_type: subject.timeline_event_type, startup: subject.startup }

      it 'returns in_progress' do
        expect(subject.status).to eq('in_progress')
      end

      context 'when event has been verified' do
        before do
          timeline_event.verify!
        end

        it 'returns completed' do
          expect(subject.status).to eq('completed')
        end
      end
    end
  end
end
