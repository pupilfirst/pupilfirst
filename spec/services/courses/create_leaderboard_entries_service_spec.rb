require "rails_helper"

describe Courses::CreateLeaderboardEntriesService do
  subject { described_class.new(course) }

  include StudentSpecHelper

  let(:evaluation_criterion_1) { create :evaluation_criterion, course: course }
  let(:evaluation_criterion_2) { create :evaluation_criterion, course: course }
  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:cohort) { create :cohort, course: course }
  let(:cohort_ended) { create :cohort, course: course, ends_at: 1.day.ago }
  let(:level_1) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level_1 }
  let(:target_1) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group
  end
  let(:target_2) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group
  end
  let(:target_3) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group
  end
  let(:target_4) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group
  end
  let(:target_5) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group
  end
  let(:team_1) { create :team_with_students, name: "s1", cohort: cohort }
  let(:team_2) { create :team_with_students, name: "s2", cohort: cohort }
  let(:team_3) { create :team_with_students, name: "s3", cohort: cohort }
  let(:team_4) { create :team_with_students, name: "s4", cohort: cohort_ended }

  let(:lts) { LeaderboardTimeService.new }

  before do
    # Link evaluation criteria to targets.
    target_1.assignments.first.evaluation_criteria << evaluation_criterion_1
    target_2.assignments.first.evaluation_criteria << evaluation_criterion_1
    target_2.assignments.first.evaluation_criteria << evaluation_criterion_2

    # Create timeline events in last week for two targets.
    passed_at = lts.week_start + 1.day

    # Complete a target with one evaluation criterion. Leaderboard score should be increased by assigned grade.
    complete_target(
      team_1.students.first,
      target_1,
      passed_at: passed_at,
      grade: 3
    )

    # Complete a target with two evaluation criteria. Leaderboard score should be increased by sum of grades (twice, in this case).
    complete_target(
      team_2.students.first,
      target_2,
      passed_at: passed_at,
      grade: 2
    )

    # Complete a target without evaluation criteria. Leaderboard score should be incremented by one.
    complete_target(team_2.students.first, target_3, passed_at: passed_at)

    # Create timeline events for two other targets, slightly outside window. These shouldn't affect the leaderboard.
    just_before = lts.week_start - 1.hour
    just_after = lts.week_end + 1.hour

    complete_target(
      team_3.students.first,
      target_4,
      passed_at: just_before,
      grade: 3
    )
    complete_target(
      team_3.students.first,
      target_5,
      passed_at: just_after,
      grade: 3
    )
    complete_target(
      team_4.students.first,
      target_4,
      passed_at: passed_at,
      grade: 2
    )
    complete_target(
      team_4.students.first,
      target_5,
      passed_at: passed_at,
      grade: 3
    )
  end

  describe "#execute" do
    it "does something" do
      expected_entry_count = team_1.students.count + team_2.students.count

      expect { subject.execute(lts.week_start, lts.week_end) }.to change {
        LeaderboardEntry.count
      }.from(0).to(expected_entry_count)

      # There should be no entry on the leaderboard for members of team_3.
      expect(
        LeaderboardEntry
          .joins(:student)
          .where(students: { id: team_3.students })
          .count
      ).to eq(0)

      # There should be no entry on the leaderboard for inactive students.
      expect(
        LeaderboardEntry
          .joins(:student)
          .where(students: { id: team_4.students })
          .count
      ).to eq(0)

      # Verify the score of all other entries.
      expect(
        LeaderboardEntry
          .joins(:student)
          .where(students: { id: team_1.students })
          .pluck(:score)
      ).to eq([3] * team_1.students.count)
      expect(
        LeaderboardEntry
          .joins(:student)
          .where(students: { id: team_2.students })
          .pluck(:score)
      ).to eq([5] * team_2.students.count)
    end
  end
end
