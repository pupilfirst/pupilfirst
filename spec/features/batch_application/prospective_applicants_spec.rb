require 'rails_helper'

feature 'Prospective Applicants' do
  context 'when no batch is open for applications' do
    let!(:previous_batch) { create :batch }

    scenario 'user can register for notification', js: true, broken: true do
      visit apply_path
      expect(page).to have_content(/Admissions to the (.*?) batch is expected to start by/)

      name = Faker::Name.name
      fill_in 'batch_applications_prospective_applicant_name', with: name
      fill_in 'batch_applications_prospective_applicant_email', with: Faker::Internet.email(name)
      fill_in 'batch_applications_prospective_applicant_phone', with: '9876543210'

      # Fill in college name because we don't want to bother with dynamically loaded select2.
      select "My college isn't listed", from: 'batch_applications_prospective_applicant_college_id'
      fill_in 'batch_applications_prospective_applicant_college_text', with: Faker::Lorem.words(3).join(' ')

      click_on 'Notify Me'

      expect(page).to have_content("We'll send you an email when admissions for the next batch is about to open")
      expect(ProspectiveApplicant.count).to eq(1)
    end
  end
end
