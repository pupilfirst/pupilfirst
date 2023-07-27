require "rails_helper"

feature "Course leaderboard" do
  include UserSpecHelper
  let(:cohort) { create :cohort }
  let(:ended_cohort) do
    create :cohort, course: cohort.course, ends_at: 1.day.ago
  end
  let(:student) { create :student, cohort: cohort }
  let(:other_student_1) { create :student, cohort: cohort }
  let(:other_student_2) { create :student, cohort: cohort }
  let(:inactive_student) { create :student, cohort: ended_cohort }
  let!(:excluded_student) do
    create :student, cohort: cohort, excluded_from_leaderboard: true
  end

  let(:school_admin) { create :school_admin, school: student.school }
  let(:lts) { LeaderboardTimeService.new }

  before do
    # Last week.
    create :leaderboard_entry,
           period_from: lts.week_start,
           period_to: lts.week_end,
           student: student,
           score: 10

    create :leaderboard_entry,
           period_from: lts.week_start,
           period_to: lts.week_end,
           student: other_student_1,
           score: rand(1..9)

    create :leaderboard_entry,
           period_from: lts.last_week_start,
           period_to: lts.last_week_end,
           student: other_student_1,
           score: 10

    create :leaderboard_entry,
           period_from: lts.last_week_start,
           period_to: lts.last_week_end,
           student: other_student_2,
           score: 7

    create :leaderboard_entry,
           period_from: lts.last_week_start,
           period_to: lts.last_week_end,
           student: student,
           score: 4
  end

  scenario "user who is not logged in visits leaderboard", js: true do
    visit leaderboard_course_path(student.course)
    expect(page).to have_text("Please sign in to continue.")
  end

  scenario "School admin visits leaderboard" do
    sign_in_user(
      school_admin.user,
      referrer: leaderboard_course_path(student.course)
    )

    expect(page).to have_content(
      "This leaderboard shows students who have improved the most compared to the previous leaderboard."
    )
  end

  scenario "Student visits leaderboard" do
    skip "The leaderboard feature is currently inactive and needs to be re-built."

    sign_in_user(
      student.user,
      referrer: leaderboard_course_path(student.course)
    )

    expect(page).to have_content("You are at the top of the leaderboard")

    # The current leaderboard should only include the current student, and members of one other team.
    ([student] + [other_student_1]).each do |leaderboard_student|
      expect(page).to have_content(leaderboard_student.name)
    end

    expect(page).not_to have_content(other_student_2.name)

    # The leaderboard shouldn't include excluded-from-leaderboard and inactive students in counts.

    # There should be 3 active students - 'student', and members of 'other_team_1'.
    within("div[data-t='active students count']") do
      expect(page).to have_text(3)
    end

    # There should be 4 inactive students - other members of "student"'s team, and members of 'other_team_2'
    within("div[data-t='inactive students count']") do
      expect(page).to have_text(4)
    end

    # The leaderboard from two weeks ago should include all students.
    visit leaderboard_course_path(
            student.course,
            on: 8.days.ago.strftime("%Y%m%d")
          )

    (
      [student] + [other_student_1] + [other_student_2]
    ).each do |leaderboard_student|
      expect(page).to have_content(leaderboard_student.name)
    end
  end
end
