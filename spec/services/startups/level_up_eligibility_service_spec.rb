require 'rails_helper'

describe Startups::LevelUpEligibilityService do
  include FounderSpecHelper

  subject { described_class.new(startup, startup.founders.first) }

  let(:course_1) { create :course }
  let!(:course_2) { create :course }
  let(:level_1) { create :level, :one, course: course_1 }
  let!(:level_2) { create :level, :two, unlock_on: 5.days.ago, course: course_1 }
  let!(:level_2_c2) { create :level, :two, unlock_on: 2.days.from_now, course: course_2 }
  let(:startup) { create :startup, level: level_1 }
  let!(:milestone_targets) { create :target_group, level: level_1, milestone: true }
  let!(:founder_target) { create :target, :for_founders, target_group: milestone_targets }
  let!(:startup_target) { create :target, :for_startup, target_group: milestone_targets }
  let!(:non_milestone_targets) { create :target_group, level: level_1 }
  let!(:non_milestone_founder_target) { create :target, :for_founders, target_group: non_milestone_targets }
  let!(:non_milestone_startup_target) { create :target, :for_startup, target_group: non_milestone_targets }

  # Presence of an archived milestone target should not alter results.
  let!(:archived_startup_target) { create :target, :for_startup, :archived, target_group: milestone_targets }

  before do
    # Create another founder in startup.
    create :founder, startup: startup
  end

  describe '#eligibility' do
    context 'when startup has submitted all milestone targets' do
      before do
        submit_target startup.founders.first, founder_target
        complete_target startup.founders.first, startup_target

        # Not all non-milestone targets need to be submitted.
        submit_target startup.founders.first, non_milestone_startup_target
      end

      context 'when the next level is open' do
        it "returns 'eligible'" do
          expect(subject.eligibility).to eq('eligible')
        end
      end

      context 'when the next level is locked' do
        before do
          level_2.update!(unlock_on: 5.days.from_now)
        end

        it "returns 'date_locked'" do
          expect(subject.eligibility).to eq('date_locked')
        end

        after do
          level_2.update!(unlock_on: 5.days.ago)
        end
      end
    end

    context 'when only one student has submitted all milestone targets' do
      it "returns 'cofounders_pending'" do
        submit_target startup.founders.first, non_milestone_founder_target
        submit_target startup.founders.first, non_milestone_startup_target
        submit_target startup.founders.first, startup_target

        # Only one student has submitted the individual target.
        create_timeline_event startup.founders.first, founder_target, passed: true

        expect(subject.eligibility).to eq('cofounders_pending')
      end
    end

    context 'when milestone targets are incomplete' do
      it "returns 'not_eligible'" do
        submit_target startup.founders.first, non_milestone_founder_target
        submit_target startup.founders.first, non_milestone_startup_target

        expect(subject.eligibility).to eq('not_eligible')
      end
    end

    context 'where there are no milestone target groups' do
      let!(:milestone_targets) { create :target_group, level: level_1, milestone: false }

      it "returns 'not_eligible'" do
        expect(subject.eligibility).to eq('not_eligible')
      end
    end

    context 'when there are more than one milestone target groups' do
      let!(:second_milestone_target_group) { create :target_group, level: level_1, milestone: true }
      let!(:milestone_founder_target_g2) { create :target, :for_founders, target_group: second_milestone_target_group }

      before do
        # Submit all targets in the first milestone target group.
        submit_target startup.founders.first, founder_target
        submit_target startup.founders.first, startup_target
      end

      context 'when the second milestone target group contains incomplete targets' do
        it "returns 'not_eligible'" do
          expect(subject.eligibility).to eq('not_eligible')
        end
      end

      context 'when the second milestone target group has also been fully completed' do
        before do
          # Submit target in the second milestone group.
          submit_target startup.founders.first, milestone_founder_target_g2
        end

        it "returns 'eligible'" do
          expect(subject.eligibility).to eq('eligible')
        end
      end
    end
  end

  describe '#eligible?' do
    context 'when eligibility is "eligible"' do
      it 'returns true' do
        allow(subject).to receive(:eligibility).and_return('eligible')
        expect(subject.eligible?).to eq(true)
      end
    end

    context 'when eligibility is not "eligible"' do
      it 'returns false' do
        %w[not_eligible cofounders_pending date_locked].each do |ineligible_marker|
          allow(subject).to receive(:eligibility).and_return(ineligible_marker)
          expect(subject.eligible?).to eq(false)
        end
      end
    end
  end

  describe '#next_level_unlock_date' do
    it 'returns the next levels unlock date' do
      expect(subject.next_level_unlock_date).to eq(5.days.ago.to_date)
    end
  end
end
