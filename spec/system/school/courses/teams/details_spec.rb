require "rails_helper"

def teams_details_path(team)
  "/school/teams/#{team.id}/details"
end

feature "Team Details", js: true do
  include UserSpecHelper
  include NotificationHelper

  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:live_cohort) { create :cohort, course: course, ends_at: 1.day.from_now }
  let!(:level) { create :level, :one, course: course }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:student_1) { create :student, cohort: live_cohort }
  let!(:team_1) { create :team_with_students, cohort: live_cohort }

  let(:name) { Faker::Lorem.words(number: 2).join(" ") }

  scenario "School admin updates name for a team and team members" do
    sign_in_user school_admin.user, referrer: teams_details_path(team_1)

    expect(page.find_field("Team name").value).to eq(team_1.name)
    expect(page).to have_button(live_cohort.name, disabled: true)

    fill_in "Team name", with: name, fill_options: { clear: :backspace }
    click_button student_1.name

    click_button "Update Team"
    dismiss_notification

    expect(team_1.reload.name).to eq(name)
    expect(team_1.students.count).to eq(3)
    expect(student_1.reload.team).to eq(team_1)

    click_button "Remove #{student_1.name}"
    click_button "Update Team"
    dismiss_notification

    expect(team_1.reload.students.count).to eq(2)
    expect(student_1.reload.team).to eq(nil)
  end

  scenario "School admin tries to disbands a team" do
    students = team_1.students
    sign_in_user school_admin.user, referrer: teams_details_path(team_1)

    expect(page.find_field("Team name").value).to eq(team_1.name)
    expect(page).to have_button(live_cohort.name, disabled: true)
    click_button "Remove #{students.first.name}"

    # Atleast two students should be present in a team.
    expect(page).to have_button("Update Team", disabled: true)

    click_button "Remove #{students.last.name}"

    # Atleast two students should be present in a team.
    expect(page).to have_button("Update Team", disabled: true)
  end

  scenario "logged in user who is not a school admin tries to access team details page" do
    sign_in_user student_1.user, referrer: teams_details_path(course)
    expect(page).to have_text("The page you were looking for doesn't exist!")
  end

  scenario "school admin tries to access an invalid link" do
    sign_in_user school_admin.user, referrer: "/school/teams/888888/details"
    expect(page).to have_text(
      "Sorry, The page you are looking for doesn't exist or has been moved."
    )
  end
end
