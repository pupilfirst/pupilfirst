require 'rails_helper'

describe Startups::RestartService do
  subject { described_class }

  let!(:tet_end_iteration) { create :tet_end_iteration }
  let!(:level_0) { create :level, number: 0 }
  let!(:level_2) { create :level, number: 2 }
  let!(:level_4) { create :level, number: 4 }
  let(:iteration) { rand(2) + 1 }
  let(:startup) { create :startup, level: level_4, iteration: iteration }
  let(:reason) { Faker::Lorem.paragraph }

  describe '#request_restart' do
    context 'when the level is lower than permitted' do
      it 'raises Startups::RestartService::LevelInvalid' do
        expect do
          subject.new(startup, startup.admin).request_restart(level_0, reason)
        end.to raise_error(Startups::RestartService::LevelInvalid)
      end
    end

    context "when level is not less than startup's level" do
      it 'raises Startups::RestartService::LevelInvalid' do
        expect do
          subject.new(startup, startup.admin).request_restart(level_4, reason)
        end.to raise_error(Startups::RestartService::LevelInvalid)
      end
    end

    context 'when the level is proper' do
      before do
        subject.new(startup, startup.admin).request_restart(level_2, reason)
      end

      it 'creates a timeline event marking end of iteration' do
        last_timeline_event = startup.timeline_events.last

        expect(last_timeline_event.timeline_event_type).to eq(tet_end_iteration)
        expect(last_timeline_event.description).to eq(reason)
        expect(last_timeline_event.founder).to eq(startup.admin)
        expect(last_timeline_event.event_on).to eq(Date.today)
      end

      it 'updates the startup' do
        expect(startup.reload.level).to eq(level_2)
        expect(startup.iteration).to eq(iteration + 1)
      end
    end
  end
end
