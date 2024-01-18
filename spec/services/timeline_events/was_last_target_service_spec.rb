require "rails_helper"

describe TimelineEvents::WasLastTargetService do
  include SubmissionsHelper

  let(:school) { create :school, :current }
  let(:course) { create :course, :with_cohort, school: school }
  let(:cohort) { course.cohorts.first }
  let(:level) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level }
  let!(:team) { create :team_with_students, cohort: cohort }
  let(:student) { team.students.first }

  let(:target) { create :target, target_group: target_group }
  let!(:assignment_target) do
    create :assignment,
           :with_default_checklist,
           :with_evaluation_criterion,
           role: Assignment::ROLE_STUDENT,
           target: target,
           milestone_number: 1,
           milestone: true
  end

  let(:target_2) { create :target, target_group: target_group }
  let!(:assignment_target_2) do
    create :assignment,
           :with_default_checklist,
           :with_evaluation_criterion,
           role: Assignment::ROLE_TEAM,
           target: target_2,
           milestone_number: 2,
           milestone: true
  end

  let(:target_3) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group
  end

  describe "#was_last_target?" do
    let(:submission_1) { complete_target(target, student) }
    let(:submission_2) { complete_target(target_2, student) }
    let(:submission_3) { complete_target(target_3, student) }
    it "returns false as student target is completed only by one team member" do
      expect(described_class.new(submission_3).was_last_target?).to eq(false)
    end
  end

  describe "#was_last_target?" do
    before { team.students.each { |f| complete_target(target, f) } }
    let(:submission_1) { complete_target(target_2, student) }

    it "returns true as all milestone submissions are passed" do
      expect(described_class.new(submission_1).was_last_target?).to eq(true)
    end
  end

  describe "#was_last_target?" do
    let(:submission) { complete_target(target, student) }
    it "returns false as only one submission is reviewed" do
      expect(described_class.new(submission).was_last_target?).to eq(false)
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

      it "returns false as only one target is completed" do
        expect(described_class.new(submission).was_last_target?).to eq(false)
      end
    end
  end
end
