require 'rails_helper'

# TODO: Prospective applicants doesn't exist any more.
feature 'Prospective Applicants', broken: true do
  before { Feature.skip_override = true }
  after { Feature.skip_override = false }

  context 'when no batch is open for applications' do
    scenario 'user can register for notification', js: true do
      visit apply_path
      expect(page).to have_content('Admissions will open in')

      name = Faker::Name.name
      fill_in 'prospective_applicants_registration_name', with: name
      fill_in 'prospective_applicants_registration_email', with: Faker::Internet.email(name)
      fill_in 'prospective_applicants_registration_phone', with: '9876543210'

      # Fill in college name because we don't want to bother with dynamically loaded select2.
      select "My college isn't listed", from: 'prospective_applicants_registration_college_id'
      fill_in 'prospective_applicants_registration_college_text', with: Faker::Lorem.words(3).join(' ')

      click_on 'Notify Me'

      expect(page).to have_content("Thank you for your interest! We'll send you an email when admissions open")
      expect(ProspectiveApplicant.count).to eq(1)
    end
  end
end
