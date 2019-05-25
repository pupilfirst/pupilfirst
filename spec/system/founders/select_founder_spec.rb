require 'rails_helper'

feature 'Select another founder profile as the active profile' do
  include UserSpecHelper

  # Three teams, with two in the same school.
  let(:startup_1) { create :startup }
  let(:startup_2) { create :startup }
  let(:another_school) { create :school }
  let(:course_in_another_school) { create :course, school: another_school }
  let(:startup_3) { create :startup, course: course_in_another_school }

  # Add milestone target groups for both courses, so that the dashboard will render correctly.
  let(:target_group_s1) { create :target_group, level: startup_1.level, milestone: true }
  let!(:target_s1) { create :target, target_group: target_group_s1 }
  let(:target_group_s2) { create :target_group, level: startup_2.level, milestone: true }
  let!(:target_s2) { create :target, target_group: target_group_s2 }

  # One student is also a member of another team.
  let!(:multi_founder_user) { startup_1.founders.first.user }
  let!(:founder_in_s2) { create :founder, startup: startup_2, user: multi_founder_user }
  let!(:founder_in_s3) { create :founder, startup: startup_3, user: multi_founder_user }
  let(:single_founder_user) { startup_2.founders.first.user }

  scenario 'Multi-founder user can switch between courses in the same school', js: true do
    sign_in_user multi_founder_user, referer: student_dashboard_path

    # The links to switch to other student profiles should not be immediately visible.
    expect(page).not_to have_link("#{startup_1.course.name} Course")
    expect(page).not_to have_link("#{startup_2.course.name} Course")

    # They should be visible within the dropdown.
    within('#nav-links__navbar') do
      click_link 'Student Dashboard'
    end

    expect(page).to have_link("#{startup_1.course.name} Course")
    expect(page).to have_link("#{startup_2.course.name} Course")

    # There still shouldn't be a link to switch to the third profile from another school, though.
    expect(page).not_to have_link("#{startup_3.course.name} Course")

    # Switch to second course.
    click_link("#{startup_2.course.name} Course")

    expect(page).to have_selector('#founder-dashboard')
    expect(page).to have_content(startup_2.name)

    # ...and back to the first course?
    within('#nav-links__navbar') do
      click_link 'Student Dashboard'
    end

    click_link("#{startup_1.course.name} Course")

    expect(page).to have_selector('#founder-dashboard')
    expect(page).to have_content(startup_1.name)
  end

  scenario 'Single-founder user does not have option to switch between courses' do
    sign_in_user single_founder_user, referer: student_dashboard_path

    expect(page).to have_link("Student Dashboard", href: '/student/dashboard')
  end
end
