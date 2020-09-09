require 'rails_helper'

feature 'Course leaderboard' do
  include UserSpecHelper

  let(:student) { create :founder }
  let(:other_team_1) { create :startup, level: student.level }
  let(:other_team_2) { create :startup, level: student.level }
  let(:inactive_team) { create :startup, level: student.level, access_ends_at: 1.day.ago }
  let!(:excluded_team) { create :startup, level: student.level }
  let(:school_admin) { create :school_admin, school: student.school }
  let(:lts) { LeaderboardTimeService.new }

  before do
    # Exlcude some students from leaderboard.
    excluded_team.founders.update(excluded_from_leaderboard: true)

    # Last week.
    create :leaderboard_entry, period_from: lts.week_start, period_to: lts.week_end, founder: student, score: 10

    other_team_1.founders.each do |founder|
      create :leaderboard_entry, period_from: lts.week_start, period_to: lts.week_end, founder: founder, score: rand(1..9)
    end

    # 2 weeks ago.
    other_team_1.founders.each do |founder|
      create :leaderboard_entry, period_from: lts.last_week_start, period_to: lts.last_week_end, founder: founder, score: 10
    end

    other_team_2.founders.each do |founder|
      create :leaderboard_entry, period_from: lts.last_week_start, period_to: lts.last_week_end, founder: founder, score: 7
    end

    create :leaderboard_entry, period_from: lts.last_week_start, period_to: lts.last_week_end, founder: student, score: 4
  end

  scenario 'user who is not logged in visits leaderboard', js: true do
    visit leaderboard_course_path(student.course)
    expect(page).to have_text("Please sign in to continue.")
  end

  scenario 'School admin visits leaderboard' do
    sign_in_user(school_admin.user, referrer: leaderboard_course_path(student.course))

    expect(page).to have_content("This leaderboard shows students who have improved the most compared to the previous leaderboard.")
  end

  scenario 'Student visits leaderboard' do
    skip 'The leaderboard feature is currently inactive, and needs to be re-built.'

    sign_in_user(student.user, referrer: leaderboard_course_path(student.course))

    expect(page).to have_content('You are at the top of the leaderboard')

    # The current leaderboard should only include the current student, and members of one other team.
    ([student] + other_team_1.founders).each do |leaderboard_founder|
      expect(page).to have_content(leaderboard_founder.name)
    end

    other_team_2.founders.each do |absent_founder|
      expect(page).not_to have_content(absent_founder.name)
    end

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
    visit leaderboard_course_path(student.course, on: 8.days.ago.strftime("%Y%m%d"))

    ([student] + other_team_1.founders + other_team_2.founders).each do |leaderboard_founder|
      expect(page).to have_content(leaderboard_founder.name)
    end
  end
end
