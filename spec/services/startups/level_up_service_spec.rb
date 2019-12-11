require 'rails_helper'

describe Startups::LevelUpService do
  include FounderSpecHelper

  subject { described_class.new(team) }

  let!(:course_1) { create :course }
  let!(:course_2) { create :course }

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
    context 'when the team is at maximum level' do
      let(:team) { create :startup, level: level_5 }

      it 'raises error' do
        expect { subject.execute }.to raise_error 'Maximum level reached - cannot level up.'
      end
    end

    context 'when team is at level 1 of 1st course' do
      let(:team) { create :startup, level: level_1 }

      it "raises team's level to 2" do
        expect { subject.execute }.to change { team.reload.level }.from(level_1).to(level_2)
      end
    end

    context 'when team is at level 3 of 2nd course' do
      let(:team) { create :startup, level: level_3_course_2 }

      it "raises team's level to 4" do
        expect { subject.execute }.to change { team.reload.level }.from(level_3_course_2).to(level_4_course_2)
      end
    end

    context 'when team is at level 2 with targets pending review in l1' do
      let(:l2_target_group) { create :target_group, level: level_2, milestone: true }
      let(:l2_target) { create :target, target_group: l2_target_group }
      let(:l1_target_group) { create :target_group, level: level_1, milestone: true }
      let(:l1_target) { create :target, target_group: l1_target_group }
      let(:team) { create :startup, level: level_2 }
      let(:student) { team.founders.first }

      before do
        submit_target student, l1_target
        complete_target student, l2_target
      end

      it 'raises error' do
        expect { subject.execute }.to raise_error "Previous level's milestones are incomplete"
      end
    end
  end
end
