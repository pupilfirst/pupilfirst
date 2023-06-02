require "rails_helper"

describe TimelineEvents::WasLastTargetService do
  include SubmissionsHelper

  let(:school) { create :school, :current }
  let(:course) { create :course, :with_cohort, school: school }
  let(:cohort) { course.cohorts.first }
  let(:level) { create :level, :one, course: course }
  let(:student) { create :student, level: level, cohort: cohort }
  let(:target_group) { create :target_group, level: level, milestone: true }

  let(:target) do
    create :target,
           :with_evaluation_criterion,
           role: Target::ROLE_STUDENT,
           target_group: target_group
  end

  describe "#was_last_target?" do
    let(:submission) { fail_target(target, student) }
    it "returns false as submission is not reviewed" do
      expect(described_class.new(submission).was_last_target?).to eq(false)
    end
  end

  describe "#was_last_target?" do
    let(:submission) { complete_target(target, student) }
    it "returns true as submission is reviewed" do
      expect(described_class.new(submission).was_last_target?).to eq(true)
    end
  end

  context "when cohort has ended" do
    before do
      cohort.ends_at = 1.day.ago
      cohort.save!
    end

    describe "#was_last_target?" do
      let(:submission) { fail_target(target, student) }

      it "returns false as submission is not reviewed" do
        expect(described_class.new(submission).was_last_target?).to eq(false)
      end
    end

    describe "#was_last_target?" do
      let(:submission) { complete_target(target, student) }

      it "returns true as submission is reviewed" do
        expect(described_class.new(submission).was_last_target?).to eq(true)
      end
    end
  end
end
