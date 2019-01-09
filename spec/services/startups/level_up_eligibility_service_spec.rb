require 'rails_helper'

describe Startups::LevelUpEligibilityService do
  include FounderSpecHelper

  subject { described_class.new(startup, startup.team_lead) }

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
        submit_target startup.team_lead, founder_target
        complete_target startup.team_lead, startup_target

        # Not all non-milestone targets need to be submitted.
        submit_target startup.team_lead, non_milestone_startup_target
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

    context 'when only admin has submitted all milestone targets' do
      it "returns 'cofounders_pending'" do
        submit_target startup.team_lead, non_milestone_founder_target
        submit_target startup.team_lead, non_milestone_startup_target
        submit_target startup.team_lead, startup_target

        # Only the admin has submitted the founder target.
        create_timeline_event startup.team_lead, founder_target, passed: true

        expect(subject.eligibility).to eq('cofounders_pending')
      end
    end

    context 'when milestone targets are incomplete' do
      it "returns 'not_eligible'" do
        submit_target startup.team_lead, non_milestone_founder_target
        submit_target startup.team_lead, non_milestone_startup_target

        expect(subject.eligibility).to eq('not_eligible')
      end
    end
  end

  describe '#eligible?' do
    context 'when startup has completed all milestone targets' do
      it 'returns true' do
        submit_target startup.team_lead, founder_target
        submit_target startup.team_lead, startup_target

        # Not all non-milestone targets need to be submitted.
        submit_target startup.team_lead, non_milestone_startup_target

        expect(subject.eligible?).to be true
      end
    end

    context 'when only admin has completed all milestone targets' do
      it 'returns false' do
        submit_target startup.team_lead, non_milestone_founder_target
        submit_target startup.team_lead, non_milestone_startup_target
        submit_target startup.team_lead, startup_target

        # Only the admin has completed the founder target.
        create_timeline_event startup.team_lead, founder_target, passed: true

        expect(subject.eligible?).to be false
      end
    end
  end

  describe '#next_level_unlock_date' do
    it 'returns the next levels unlock date' do
      expect(subject.next_level_unlock_date).to eq(5.days.ago.to_date)
    end
  end
end
