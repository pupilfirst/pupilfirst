require 'rails_helper'

feature 'Inactive students index', js: true do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:level_1) { create :level, :one, course: course }

  let!(:inactive_team) { create :startup, level: level_1, access_ends_at: 1.day.ago, dropped_out_at: 1.day.ago }
  let!(:access_ended_team) { create :startup, level: level_1, access_ends_at: 1.day.ago }
  let!(:exited_team) { create :startup, level: level_1, dropped_out_at: 1.day.ago }
  let!(:active_team) { create :startup, level: level_1 }

  scenario 'School admin manipulates inactive teams' do
    sign_in_user school_admin.user, referrer: school_course_inactive_students_path(course)

    expect(page).not_to have_text(active_team.founders.first.name)

    access_ended_student = access_ended_team.founders.first
    expect(page).to have_text(access_ended_student.name)

    check "select-team-#{access_ended_team.id}"
    click_button 'Reactivate Students'

    expect(page).to have_text("Teams marked active successfully!")
    expect(access_ended_team.reload.access_ends_at).to eq(nil)

    dismiss_notification
    exited_student = exited_team.founders.first
    expect(page).to have_text(exited_student.name)

    check "select-team-#{exited_team.id}"
    click_button 'Reactivate Students'

    expect(page).to have_text("Teams marked active successfully!")
    expect(exited_team.reload.dropped_out_at).to eq(nil)

    inactive_student = inactive_team.founders.first
    expect(page).to have_text(inactive_student.name)

    dismiss_notification
    check "select-team-#{inactive_team.id}"
    click_button 'Reactivate Students'

    expect(page).to have_text("Teams marked active successfully!")
    expect(inactive_team.reload.dropped_out_at).to eq(nil)
    expect(inactive_team.access_ends_at).to eq(nil)
  end

  scenario 'School can filter teams and students' do
    sign_in_user school_admin.user, referrer: school_course_inactive_students_path(course)

    fill_in 'search', with: access_ended_team.name
    click_link 'Search'
    expect(page).to have_text(access_ended_team.founders.first.name)
    expect(page).to have_text(access_ended_team.founders.last.name)

    fill_in 'search', with: exited_team.founders.first.name
    click_link 'Search'
    expect(page).to have_text(exited_team.founders.first.name)
    expect(page).to have_text(exited_team.name)
  end
end
