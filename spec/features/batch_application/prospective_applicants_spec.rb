require 'rails_helper'

feature 'Prospective Applicants' do
  context 'when no batch is open for applications' do
    let!(:previous_batch) { create :batch }
    let!(:college) { create :college }

    scenario 'user can register for notification' do
      visit apply_path
      expect(page).to have_content(/Admissions to Batch #\d{1,3} is expected to start on/)

      name = Faker::Name.name
      fill_in 'prospective_applicant_name', with: name
      fill_in 'prospective_applicant_email', with: Faker::Internet.email(name)
      fill_in 'prospective_applicant_phone', with: '9876543210'
      fill_in 'prospective_applicant_college_id', with: college.id

      click_on 'Notify Me'

      expect(page).to have_content("We'll send you an email when admissions for the next batch is about to open")
    end
  end
end
