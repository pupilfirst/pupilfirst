require "rails_helper"

def cohorts_actions_path(cohort)
  "/school/cohorts/#{cohort.id}/actions"
end

feature "Cohorts Actions", js: true do
  include UserSpecHelper
  include NotificationHelper

  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:live_cohort) { create :cohort, course: course, ends_at: 1.day.from_now }
  let!(:ended_cohort) { create :cohort, course: course, ends_at: 1.day.ago }
  let!(:level) { create :level, :one, course: course }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:student) { create :student, cohort: live_cohort }
  let!(:student_ended) { create :student, cohort: ended_cohort }
  let!(:team_ended) { create :team_with_students, cohort: ended_cohort }

  scenario "School admin merges ended cohort into live cohort" do
    sign_in_user school_admin.user, referrer: cohorts_actions_path(ended_cohort)

    expect(page).to have_text("Merge #{ended_cohort.name} into another cohort")
    click_button "Pick a Cohort"
    click_button live_cohort.name
    click_button "Merge and delete"

    dismiss_notification

    expect(page).to have_text(live_cohort.name)
    expect(page).not_to have_text(ended_cohort.name)

    expect(student_ended.reload.cohort).to eq(live_cohort)
    expect(team_ended.reload.cohort).to eq(live_cohort)
    expect(course.cohorts.count).to eq(1)
  end

  scenario "logged in user who is not a school admin tries to access cohorts action page" do
    sign_in_user student.user, referrer: cohorts_actions_path(course)
    expect(page).to have_text("The page you were looking for doesn't exist!")
  end

  scenario "school admin tries to access an invalid link" do
    sign_in_user school_admin.user, referrer: "/school/cohorts/888888/actions"
    expect(page).to have_text(
      "Sorry, The page you are looking for doesn't exist or has been moved."
    )
  end
end
