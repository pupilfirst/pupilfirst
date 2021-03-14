require 'rails_helper'

feature 'Applicant Index', js: true do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:applicant_1) do
    create :applicant, :verified, course: course, name: 'Pupilfirst Applicant'
  end
  let!(:applicant_2) { create :applicant, :verified, course: course }

  context 'with many applicants' do
    before { 23.times { create :applicant, :verified, course: course } }

    scenario 'school admin loads all applicants' do
      sign_in_user school_admin.user,
                   referrer: applicants_school_course_path(course)

      expect(page).to have_text('Showing 10 of 25 applicants')
      click_button 'Load More Applicants...'

      expect(page).to have_text('Showing 20 of 25 applicants')
      click_button 'Load More Applicants...'

      expect(page).to have_text('Showing all 25 applicants')
      expect(page).not_to have_text('Load More Applicants...')
    end
  end

  scenario 'user who is not logged in gets redirected to sign in page' do
    visit applicants_school_course_path(course)
    expect(page).to have_text('Please sign in to continue.')
  end

  scenario 'school admin searches and filters applicants' do
    sign_in_user school_admin.user,
                 referrer: applicants_school_course_path(course)

    within("div[id='applicants']") do
      expect(page).to have_text(applicant_1.name)
      expect(page).to have_text(applicant_2.name)
    end

    fill_in('Search', with: 'Pupilfirst Applicant')
    click_button 'Pick Search by name or email: Pupilfirst Applicant'

    within("div[id='applicants']") do
      expect(page).to have_text(applicant_1.name)
      expect(page).not_to have_text(applicant_2.name)
    end
  end
end
