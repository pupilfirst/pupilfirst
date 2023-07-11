require "rails_helper"

describe Schools::MilestoneSortService do
  subject { described_class.new(target_1, "down") }
  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level_1, sort_index: 1 }
  let!(:target_1) do
    create :target,
           :student,
           target_group: target_group,
           milestone: true,
           milestone_number: 1
  end
  let!(:target_2) do
    create :target,
           :student,
           target_group: target_group,
           milestone: true,
           milestone_number: 4
  end

  describe "#execute" do
    it "swaps milestone numbers of two targets based on the target and direction passed" do
      expect { subject.execute }.to change {
        target_1.reload.milestone_number
      }.from(1).to(2)
      .and change {
       target_2.reload.milestone_number 
      }.from(4).to(1)
    end
  end
end
