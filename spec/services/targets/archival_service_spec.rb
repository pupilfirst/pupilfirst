require 'rails_helper'

describe Targets::ArchivalService do
  subject { described_class.new(target) }

  let(:target) { create :target }
  let!(:target_with_prerequisite) { create :target, prerequisite_targets: [target] }

  describe '#archive' do
    it 'removes itself as a prerequisite from all linked targets' do
      expect { subject.archive }.to change { target_with_prerequisite.reload.prerequisite_targets.count }.from(1).to(0)
    end

    it 'archives the target' do
      expect { subject.archive }.to change { target.reload.archived }.from(false).to(true)
    end
  end
end
