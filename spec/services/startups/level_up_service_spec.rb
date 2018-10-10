require 'rails_helper'

describe Startups::LevelUpService do
  subject { described_class.new(startup) }

  let!(:school_1) { create :school }
  let!(:school_2) { create :school }

  let!(:level_0) { create :level, :zero, school: school_1 }
  let!(:level_1) { create :level, :one, school: school_1 }
  let!(:level_2) { create :level, :two, school: school_1 }
  let!(:level_3) { create :level, :three, school: school_1 }
  let!(:level_4) { create :level, :four, school: school_1 }
  let!(:level_5) { create :level, :five, school: school_1 }

  let!(:level_1_school_2) { create :level, :one, school: school_2 }
  let!(:level_2_school_2) { create :level, :two, school: school_2 }
  let!(:level_3_school_2) { create :level, :three, school: school_2 }
  let!(:level_4_school_2) { create :level, :four, school: school_2 }
  let!(:level_5_school_2) { create :level, :five, school: school_2 }

  let!(:joined_svco_tet) { create :tet_joined }
  describe '#execute' do
    context 'when the startup is at maximum level' do
      let(:startup) { create :startup, level: level_5 }

      it 'raises error' do
        expect { subject.execute }.to raise_error 'Maximum level reached - cannot level up.'
      end
    end

    context 'when startup is at level 1 of 1st school' do
      let(:startup) { create :startup, level: level_1 }

      it "raises startup's level to 2" do
        expect { subject.execute }.to change { startup.reload.level }.from(level_1).to(level_2)
      end
    end

    context 'when startup is at level 3 of 2nd school' do
      let(:startup) { create :startup, level: level_3_school_2 }

      it "raises startup's level to 4" do
        expect { subject.execute }.to change { startup.reload.level }.from(level_3_school_2).to(level_4_school_2)
      end
    end

    context 'when startup is at level 0' do
      let(:startup) { create :startup, level: level_0 }
      let!(:exited_founder) { create :founder, startup: startup, exited: true }

      it 'successfully enrolls the startup to level 1' do
        # Non-exited founders of the startup will be tagged 'Moved to Level 1' on Intercom
        expect(Intercom::FounderTaggingJob).to receive(:perform_later).with(startup.team_lead, 'Moved to Level 1')
        expect(Intercom::FounderTaggingJob).to_not receive(:perform_later).with(exited_founder, 'Moved to Level 1')
        subject.execute

        # startup must have moved to Level 1.
        expect(startup.level).to eq(level_1)

        # program_started_on must have been set.
        expect(startup.program_started_on).to_not eq(nil)
        expect(startup.admission_stage).to eq(Startup::ADMISSION_STAGE_ADMITTED)

        # A verified Joined SV event must have been created.
        event = startup.timeline_events.last
        expect(event.timeline_event_type).to eq(joined_svco_tet)
        expect(event.status).to eq(TimelineEvent::STATUS_VERIFIED)
      end
    end
  end
end
