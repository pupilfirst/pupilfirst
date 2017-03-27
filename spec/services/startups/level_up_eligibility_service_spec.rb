require 'rails_helper'

describe Startups::LevelUpEligibilityService do
  include FounderSpecHelper

  subject { described_class.new(startup) }

  let(:level_1) { create :level, number: 1 }
  let(:startup) { create :startup, level: level_1 }
  let(:milestone_targets) { create :target_group, level: level_1, milestone: true }
  let(:founder_target) { create :target, :for_founders, target_group: milestone_targets }
  let(:startup_target) { create :target, :for_startup, target_group: milestone_targets }
  let(:non_milestone_targets) { create :target_group, level: level_1 }
  let(:non_milestone_founder_target) { create :target, :for_founders, target_group: non_milestone_targets }
  let(:non_milestone_startup_target) { create :target, :for_startup, target_group: non_milestone_targets }

  describe '#eligible?' do
    context 'when startup has completed all milestone targets' do
      it 'returns true' do
        complete_target startup.admin, founder_target
        complete_target startup.admin, startup_target

        # Not all non-milestone targets need to be completed.
        complete_target startup.admin, non_milestone_startup_target

        expect(subject.eligible?).to be true
      end
    end

    context 'when startup has completed all milestone targets' do
      it 'returns true' do
        complete_target startup.admin, non_milestone_founder_target
        complete_target startup.admin, non_milestone_startup_target
        complete_target startup.admin, startup_target

        # Only the admin has completed the founder target.
        create_verified_timeline_event startup.admin, founder_target

        expect(subject.eligible?).to be false
      end
    end
  end
end
