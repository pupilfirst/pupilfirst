require "rails_helper"

def teams_new_path(course)
  "/school/courses/#{course.id}/teams/new"
end

feature "Teams New", js: true do
  include UserSpecHelper
  include NotificationHelper

  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:live_cohort) { create :cohort, course: course }
  let!(:level) { create :level, :one, course: course }
  let!(:level_two) { create :level, :two, course: course }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:student_1) { create :student, cohort: live_cohort }
  let!(:student_2) { create :student, cohort: live_cohort }
  let!(:student_3) { create :student, cohort: live_cohort }
  let!(:team_1) { create :team_with_students, cohort: live_cohort }
  let(:name) { Faker::Lorem.words(number: 2).join(" ") }

  scenario "School admin creates a cohort" do
    sign_in_user school_admin.user, referrer: teams_new_path(course)

    expect(page).to have_text("Create new team")

    fill_in "Team name", with: name

    click_button "Pick a Cohort"
    click_button live_cohort.name

    expect(page).to have_text("No students selected")

    expect(page).not_to have_text(team_1.students.first.name)
    expect(page).not_to have_text(team_1.students.last.name)

    click_button student_1.name
    click_button student_2.name
    click_button student_3.name

    click_button "Add new team"

    dismiss_notification

    within("div[data-team-name='#{name}']") do
      expect(page).to have_text(student_1.name)
      expect(page).to have_text(student_2.name)
      expect(page).to have_text(student_3.name)
    end

    team = Team.last

    expect(team.name).to eq(name)
    expect(team.students.count).to eq(3)
  end

  scenario "School admin creates a team with one student" do
    sign_in_user school_admin.user, referrer: teams_new_path(course)
    expect(page).to have_text("Create new team")

    fill_in "Team name", with: name

    click_button "Pick a Cohort"
    click_button live_cohort.name

    expect(page).to have_text("No students selected")

    click_button "Add new team", disabled: true

    click_button student_1.name

    # You need to select at least two students to create a team.
    expect(page).to have_button("Add new team", disabled: true)
  end

  scenario "logged in user who is not a school admin tries to access create team page" do
    sign_in_user student_1.user, referrer: teams_new_path(course)
    expect(page).to have_text("The page you were looking for doesn't exist!")
  end

  scenario "school admin tries to access an invalid link" do
    sign_in_user school_admin.user,
                 referrer: "/school/courses/888888/cohorts/new"
    expect(page).to have_text(
      "Sorry, The page you are looking for doesn't exist or has been moved."
    )
  end
end
