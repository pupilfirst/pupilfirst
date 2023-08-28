require "rails_helper"

describe Targets::UpdateVisibilityService do
  subject { described_class }

  let(:target_group) { create :target_group }
  let(:prerequisite_target) { create :target, target_group: target_group }
  let(:target) do
    create :target,
           target_group: target_group,
           prerequisite_targets: [prerequisite_target],
           milestone: true,
           milestone_number: 1
  end

  context "when the requested visibility is archived" do
    let!(:another_target) do
      create :target, target_group: target_group, prerequisite_targets: [target]
    end

    it "removes prerequisites from target and resets milestone" do
      expect(another_target.prerequisite_targets.count).to eq(1)

      expect {
        subject.new(target, Target::VISIBILITY_ARCHIVED).execute
      }.to change { target.prerequisite_targets.count }.from(1).to(0)

      expect(another_target.prerequisite_targets.count).to eq(0)

      expect(target.milestone).to eq(false)
      expect(target.milestone_number).to eq(nil)
    end

    it "updates visibility" do
      expect {
        subject.new(target, Target::VISIBILITY_ARCHIVED).execute
      }.to change { target.reload.visibility }.from(Target::VISIBILITY_LIVE).to(
        Target::VISIBILITY_ARCHIVED
      )
    end
  end

  context "when the requested visibility is live" do
    let(:target_group_archival_service) do
      instance_double(TargetGroups::ArchivalService, unarchive: true)
    end
    let(:target) do
      create :target,
             :draft,
             target_group: target_group,
             prerequisite_targets: [prerequisite_target]
    end

    it "uses TargetGroups::ArchivalService to unarchive target group" do
      expect(TargetGroups::ArchivalService).to receive(:new).with(
        target_group
      ).and_return(target_group_archival_service)
      expect(target_group_archival_service).to receive(:unarchive)

      expect do
        subject.new(target, Target::VISIBILITY_LIVE).execute
      end.to change { target.reload.visibility }.from(
        Target::VISIBILITY_DRAFT
      ).to(Target::VISIBILITY_LIVE)
    end
  end

  context "when the requested visibility is draft" do
    let(:target_group_archival_service) do
      instance_double(TargetGroups::ArchivalService, unarchive: true)
    end
    let(:target) do
      create :target,
             :archived,
             target_group: target_group,
             prerequisite_targets: [prerequisite_target]
    end

    it "uses TargetGroups::ArchivalService to unarchive target group" do
      expect(TargetGroups::ArchivalService).to receive(:new).with(
        target_group
      ).and_return(target_group_archival_service)
      expect(target_group_archival_service).to receive(:unarchive)

      expect do
        subject.new(target, Target::VISIBILITY_DRAFT).execute
      end.to change { target.reload.visibility }.from(
        Target::VISIBILITY_ARCHIVED
      ).to(Target::VISIBILITY_DRAFT)
    end
  end
end
