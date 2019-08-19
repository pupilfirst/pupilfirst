require 'rails_helper'

describe Courses::CreateLeaderboardEntriesService do
  subject { described_class.new(course) }

  include FounderSpecHelper

  let(:evaluation_criterion_1) { create :evaluation_criterion, course: course }
  let(:evaluation_criterion_2) { create :evaluation_criterion, course: course }
  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level_1 }
  let(:target_1) { create :target, :for_founders, target_group: target_group }
  let(:target_2) { create :target, :for_founders, target_group: target_group }
  let(:target_3) { create :target, :for_founders, target_group: target_group }
  let(:target_4) { create :target, :for_founders, target_group: target_group }
  let(:target_5) { create :target, :for_founders, target_group: target_group }
  let(:startup_1) { create :startup, level: level_1, name: 's1' }
  let(:startup_2) { create :startup, level: level_1, name: 's2' }
  let(:startup_3) { create :startup, level: level_1, name: 's3' }
  let(:startup_4) { create :startup, level: level_1, name: 's4', access_ends_at: 1.day.ago }

  let(:lts) { LeaderboardTimeService.new }

  before do
    # Link evaluation criteria to targets.
    target_1.evaluation_criteria << evaluation_criterion_1
    target_2.evaluation_criteria << evaluation_criterion_1
    target_2.evaluation_criteria << evaluation_criterion_2

    # Create timeline events in last week for two targets.
    passed_at = lts.week_start + 1.day

    # Complete a target with one evaluation criterion. Leaderboard score should be increased by assigned grade.
    complete_target(startup_1.founders.first, target_1, passed_at: passed_at, grade: 3)

    # Complete a target with two evaluation criteria. Leaderboard score should be increased by sum of grades (twice, in this case).
    complete_target(startup_2.founders.first, target_2, passed_at: passed_at, grade: 2)

    # Complete a target without evaluation criteria. Leaderboard score should be incremented by one.
    complete_target(startup_2.founders.first, target_3, passed_at: passed_at)

    # Create timeline events for two other targets, slightly outside window. These shouldn't affect the leaderboard.
    just_before = lts.week_start - 1.hour
    just_after = lts.week_end + 1.hour

    complete_target(startup_3.founders.first, target_4, passed_at: just_before, grade: 3)
    complete_target(startup_3.founders.first, target_5, passed_at: just_after, grade: 3)
    complete_target(startup_4.founders.first, target_4, passed_at: passed_at, grade: 2)
    complete_target(startup_4.founders.first, target_5, passed_at: passed_at, grade: 3)
  end

  describe '#execute' do
    it 'does something' do
      expected_entry_count = startup_1.founders.count + startup_2.founders.count

      expect do
        subject.execute(lts.week_start, lts.week_end)
      end.to change { LeaderboardEntry.count }.from(0).to(expected_entry_count)

      # There should be no entry on the leaderboard for members of startup_3.
      expect(LeaderboardEntry.joins(:founder).where(founders: { id: startup_3.founders }).count).to eq(0)

      # There should be no entry on the leaderboard for inactive students.
      expect(LeaderboardEntry.joins(:founder).where(founders: { id: startup_4.founders }).count).to eq(0)

      # Verify the score of all other entries.
      expect(LeaderboardEntry.joins(:founder).where(founders: { id: startup_1.founders }).pluck(:score)).to eq([3] * startup_1.founders.count)
      expect(LeaderboardEntry.joins(:founder).where(founders: { id: startup_2.founders }).pluck(:score)).to eq([5] * startup_2.founders.count)
    end
  end
end
