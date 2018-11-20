require 'rails_helper'

describe TimelineEvents::DeleteLatestSubmissionRecordService do
  subject { described_class.new(timeline_event) }
  let(:founder_target) { create :target, role: Target::ROLE_FOUNDER }
  let(:team_target) { create :target, role: Target::ROLE_TEAM }
  let(:startup) { create :startup }
  let(:founder) { create :founder, startup: startup }
  let!(:timeline_event) { create :timeline_event, target: founder_target, founder: founder }

  describe '#execute' do
    context 'when a timeline event is deleted for a founder target' do
      it 'delete latest submission record for the founder' do
        timeline_event.destroy!

        expect(LatestSubmissionRecord.count).to eq(0)
      end
    end

    context 'when a timeline event is deleted for a team target' do
      let!(:timeline_event) { create :timeline_event, target: team_target, founder: founder }

      it 'delete latest submission record for all founders in the team' do
        timeline_event.destroy!

        expect(LatestSubmissionRecord.count).to eq(0)
      end
    end

    context 'when a new timeline event is deleted for a founder target with a latest submission record' do
      let!(:timeline_event_1) { create :timeline_event, target: founder_target, founder: founder }
      let!(:timeline_event_2) { create :timeline_event, target: founder_target, founder: founder }

      it 'update latest submission record' do
        timeline_event_2.destroy!
        expect(LatestSubmissionRecord.where(target: founder_target).last.timeline_event).to eq(timeline_event_1)
        expect(LatestSubmissionRecord.count).to eq(1)
      end
    end
  end
end
