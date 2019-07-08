require 'rails_helper'

describe Targets::UpdateVisibilityService do
  subject { described_class }

  let(:target_group) { create :target_group }
  let(:prerequisite_target) { create :target, target_group: target_group }
  let(:target) { create :target, target_group: target_group, prerequisite_targets: [prerequisite_target] }

  shared_examples "removes prerequisites and updates non-live visibility" do |requested_visibility|
    let(:visibility) { requested_visibility }

    it 'removes prerequisites from target' do
      expect do
        subject.new(target, visibility).execute
      end.to change { target.prerequisite_targets.count }.from(1).to(0)
    end

    it 'updates visibility' do
      expect do
        subject.new(target, visibility).execute
      end.to change { target.reload.visibility }.from(Target::VISIBILITY_LIVE).to(visibility)
    end
  end

  include_examples "removes prerequisites and updates non-live visibility", Target::VISIBILITY_DRAFT
  include_examples "removes prerequisites and updates non-live visibility", Target::VISIBILITY_ARCHIVED

  context "when the requested visibility is live" do
    let(:target_group_archival_service) { instance_double(TargetGroups::ArchivalService, unarchive: true) }
    let(:target) { create :target, :draft, target_group: target_group, prerequisite_targets: [prerequisite_target] }

    it 'uses TargetGroups::ArchivalService to unarchive target group' do
      expect(TargetGroups::ArchivalService).to receive(:new).with(target_group).and_return(target_group_archival_service)
      expect(target_group_archival_service).to receive(:unarchive)

      expect do
        subject.new(target, Target::VISIBILITY_LIVE).execute
      end.to change { target.reload.visibility }.from(Target::VISIBILITY_DRAFT).to(Target::VISIBILITY_LIVE)
    end
  end
end
