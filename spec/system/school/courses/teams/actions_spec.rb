require 'rails_helper'

def teams_actions_path(team_1)
  "/school/teams/#{team_1.id}/actions"
end

feature 'Team Actions', js: true do
  include UserSpecHelper
  include NotificationHelper

  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:live_cohort) { create :cohort, course: course, ends_at: 1.day.from_now }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:team_1) { create :team_with_students, cohort: live_cohort }
  let!(:team_2) { create :team_with_students, cohort: live_cohort }

  scenario 'School admin merges ended cohort into live cohort' do
    students = team_1.students

    sign_in_user school_admin.user, referrer: teams_actions_path(team_1)

    expect(page).to have_text(team_1.name)
    click_button 'Delete team'

    dismiss_notification

    expect(page).to have_text(team_2.name)
    expect(page).not_to have_text(team_1.name)

    students.each { |student| expect(student.reload.team).to eq(nil) }
    expect(course.teams.count).to eq(1)
  end

  scenario 'logged in user who is not a school admin tries to access teams action page' do
    sign_in_user team_1.students.first.user,
                 referrer: teams_actions_path(team_1)
    expect(page).to have_text("The page you were looking for doesn't exist!")
  end

  scenario 'school admin tries to access an invalid link' do
    sign_in_user school_admin.user, referrer: '/school/teams/888888/actions'
    expect(page).to have_text("Sorry, The page you are looking for doesn't exist or has been moved.")
  end
end
