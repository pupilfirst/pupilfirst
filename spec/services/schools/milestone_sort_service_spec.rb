require "rails_helper"

describe Schools::MilestoneSortService do
  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level_1, sort_index: 1 }
  let!(:target_1) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group,
           given_milestone_number: 1
  end
  let!(:target_2) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group,
           given_milestone_number: 4
  end
  let!(:archived_target) do
    create :target,
           :with_shared_assignment,
           :archived,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group,
           archived: true,
           given_milestone_number: 3
  end

  describe "#execute" do
    it "swaps specified target down" do
      expect { described_class.new(target_1, "down").execute }.to change {
        target_1.reload.assignments.first.milestone_number
      }.from(1).to(2).and change {
              target_2.reload.assignments.first.milestone_number
            }.from(4).to(1)
      expect(archived_target.reload.assignments.first.milestone_number).to eq(3)
    end

    it "swaps specified target up" do
      expect { described_class.new(target_2, "up").execute }.to change {
        target_1.reload.assignments.first.milestone_number
      }.from(1).to(2).and change {
              target_2.reload.assignments.first.milestone_number
            }.from(4).to(1)
    end

    it "does not swap target up" do
      expect { described_class.new(target_1, "up").execute }.not_to change {
        target_1.reload.assignments.first.milestone_number
      }.from(1)
      expect(target_2.reload.assignments.first.milestone_number).to eq(4)
    end

    it "does not swap target down" do
      expect { described_class.new(target_2, "down").execute }.not_to change {
        target_2.reload.assignments.first.milestone_number
      }.from(4)
      expect(target_1.reload.assignments.first.milestone_number).to eq(1)
    end

    it "does not swap target, when target is not milestone" do
      expect {
        described_class.new(archived_target, "up").execute
      }.not_to change {
        archived_target.reload.assignments.first.milestone_number
      }.from(3)

      expect(target_1.reload.assignments.first.milestone_number).to eq(1)
      expect(target_2.reload.assignments.first.milestone_number).to eq(4)
    end
  end
end
