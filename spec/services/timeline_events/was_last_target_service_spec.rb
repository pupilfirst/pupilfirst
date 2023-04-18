require "rails_helper"

describe TimelineEvents::WasLastTargetService do
  let(:school) { create :school, :current }
  let(:course) { create :course, :with_cohort, school: school }
  let(:cohort) { course.cohorts.first }
  let(:level) { create :level, :one, course: course }
  let(:student) { create :student, level: level, cohort: cohort }

  let(:target_group) { create :target_group, level: level, milestone: true }
  let(:target) do
    create :target, role: Target::ROLE_STUDENT, target_group: target_group
  end
  let(:target_group_1) { create :target_group, level: level, milestone: true }
  let(:target_1) do
    create :target, role: Target::ROLE_STUDENT, target_group: target_group_1
  end

  let!(:submission_1) do
    create(
      :timeline_event,
      :with_owners,
      owners: [student],
      latest: true,
      target: target
    )
  end

  let!(:submission_2) do
    create(
      :timeline_event,
      :with_owners,
      owners: [student],
      target: target_1,
      latest: true
    )
  end

  def mark_submission_as_reviewed(submission)
    submission.evaluated_at = 1.day.ago
    submission.evaluator_id = create(:faculty).id
    submission.passed_at = 1.day.ago
    submission.save
  end

  def mark_submission_as_not_reviewed(submission)
    submission.evaluated_at = nil
    submission.evaluator_id = nil
    submission.passed_at = nil
    submission.save
  end

  context "when cohort is not ended" do
    describe "#was_last_target?" do
      before do
        cohort.ends_at = 1.day.from_now
        cohort.save
      end

      it "returns false as submission is not reviewed" do
        expect(described_class.new(submission_1).was_last_target?).to eq(false)
      end
    end

    describe "#was_last_target?" do
      before do
        mark_submission_as_reviewed(submission_1)
        mark_submission_as_reviewed(submission_2)
      end

      it "returns true as submission is reviewed" do
        expect(described_class.new(submission_2).was_last_target?).to eq(true)
      end
    end
  end

  context "when cohort is ended" do
    describe "#was_last_target?" do
      before do
        cohort.ends_at = 1.day.ago
        cohort.save
        # keep submission_1 as reviewed
        mark_submission_as_not_reviewed(submission_2)
      end

      it "returns false as submission is not reviewed" do
        expect(described_class.new(submission_1).was_last_target?).to eq(false)
      end
    end

    describe "#was_last_target?" do
      before do
        mark_submission_as_reviewed(submission_1)
        mark_submission_as_reviewed(submission_2)
      end

      it "returns true as submission is reviewed" do
        expect(described_class.new(submission_2).was_last_target?).to eq(true)
      end
    end
  end
end
