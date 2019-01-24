require 'rails_helper'

describe Startups::LevelUpService do
  subject { described_class.new(startup) }

  let!(:course_1) { create :course }
  let!(:course_2) { create :course }

  let!(:level_0) { create :level, :zero, course: course_1 }
  let!(:level_1) { create :level, :one, course: course_1 }
  let!(:level_2) { create :level, :two, course: course_1 }
  let!(:level_3) { create :level, :three, course: course_1 }
  let!(:level_4) { create :level, :four, course: course_1 }
  let!(:level_5) { create :level, :five, course: course_1 }

  let!(:level_1_course_2) { create :level, :one, course: course_2 }
  let!(:level_2_course_2) { create :level, :two, course: course_2 }
  let!(:level_3_course_2) { create :level, :three, course: course_2 }
  let!(:level_4_course_2) { create :level, :four, course: course_2 }
  let!(:level_5_course_2) { create :level, :five, course: course_2 }

  describe '#execute' do
    context 'when the startup is at maximum level' do
      let(:startup) { create :startup, level: level_5 }

      it 'raises error' do
        expect { subject.execute }.to raise_error 'Maximum level reached - cannot level up.'
      end
    end

    context 'when startup is at level 1 of 1st course' do
      let(:startup) { create :startup, level: level_1 }

      it "raises startup's level to 2" do
        expect { subject.execute }.to change { startup.reload.level }.from(level_1).to(level_2)
      end
    end

    context 'when startup is at level 3 of 2nd course' do
      let(:startup) { create :startup, level: level_3_course_2 }

      it "raises startup's level to 4" do
        expect { subject.execute }.to change { startup.reload.level }.from(level_3_course_2).to(level_4_course_2)
      end
    end

    context 'when startup is at level 0' do
      let(:startup) { create :startup, level: level_0 }
      let!(:exited_founder) { create :founder, startup: startup, exited: true }

      it 'successfully enrolls the startup to level 1' do
        # Non-exited founders of the startup will be tagged 'Moved to Level 1' on Intercom
        expect(Intercom::FounderTaggingJob).to receive(:perform_later).with(startup.founders.first, 'Moved to Level 1')
        expect(Intercom::FounderTaggingJob).to_not receive(:perform_later).with(exited_founder, 'Moved to Level 1')
        subject.execute

        # startup must have moved to Level 1.
        expect(startup.level).to eq(level_1)

        # program_started_on must have been set.
        expect(startup.program_started_on).to_not eq(nil)
        expect(startup.admission_stage).to eq(Startup::ADMISSION_STAGE_ADMITTED)
      end
    end
  end
end
