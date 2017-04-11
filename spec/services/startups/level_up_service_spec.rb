require 'rails_helper'

describe Startups::LevelUpService do
  subject { described_class.new(startup) }

  let!(:level_0) { create :level, :zero }
  let!(:level_1) { create :level, :one }
  let!(:level_2) { create :level, :two }
  let!(:level_5) { create :level, :five }

  let!(:joined_svco_tet) { create :tet_joined }

  describe '#execute' do
    context 'when the startup is at maximum level' do
      let(:startup) { create :startup, level: level_5 }

      it 'raises error' do
        expect { subject.execute }.to raise_error 'Maximum level reached - cannot level up.'
      end
    end

    context 'when startup is at level 1' do
      let(:startup) { create :startup, level: level_1 }

      it "raises startup's level to 2" do
        expect { subject.execute }.to change { startup.reload.level }.from(level_1).to(level_2)
      end
    end

    context 'when startup is at level 0' do
      let(:startup) { create :startup, level: level_0 }

      it 'successfully enrolls the startup to level 1' do
        subject.execute

        # startup must have moved to level 1
        expect(startup.level).to eq(level_1)
        # program_started_on must have been set
        expect(startup.program_started_on).to_not eq(nil)
        # A verified Joined SV event must have been created
        event = startup.timeline_events.last
        expect(event.timeline_event_type).to eq(joined_svco_tet)
        expect(event.verified_status).to eq(TimelineEvent::VERIFIED_STATUS_VERIFIED)
      end
    end
  end
end
