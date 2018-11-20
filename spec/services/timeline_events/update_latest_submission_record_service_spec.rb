require 'rails_helper'

describe TimelineEvents::UpdateLatestSubmissionRecordService do
  subject { described_class.new(timeline_event) }
  let(:founder_target) { create :target, role: Target::ROLE_FOUNDER }
  let(:team_target) { create :target, role: Target::ROLE_TEAM }
  let(:startup) { create :startup }
  let(:founder) { create :founder, startup: startup }

  describe '#execute' do
    context 'when a timeline event is created for a founder target' do
      let!(:timeline_event) { create :timeline_event, target: founder_target, founder: founder }

      it 'create latest submission record for founder' do
        expect(LatestSubmissionRecord.where(founder: founder).last.timeline_event).to eq(timeline_event)
        expect(LatestSubmissionRecord.count).to eq(1)
      end
    end

    context 'when a timeline event is created for a team target' do
      let!(:timeline_event) { create :timeline_event, target: team_target, founder: founder }

      it 'create latest submission record for all founders in the team' do
        expect(LatestSubmissionRecord.where(target: team_target).count).to eq(timeline_event.startup.founders.count)
      end
    end

    context 'when a new timeline event is created for a founder target with a latest submission record' do
      let!(:timeline_event_1) { create :timeline_event, target: founder_target, founder: founder }
      let!(:timeline_event_2) { create :timeline_event, target: founder_target, founder: founder }

      it 'update latest submission record' do
        expect(LatestSubmissionRecord.where(target: founder_target).last.timeline_event).to eq(timeline_event_2)
        expect(LatestSubmissionRecord.count).to eq(1)
      end
    end
  end
end
