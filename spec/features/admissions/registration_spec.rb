require 'rails_helper'

feature 'Founder Registration' do
  let(:startup) { create :startup }
  let(:founder) { create :founder }

  # setup minimum stuff to display a dashboard
  let!(:level_0) { create :level, :zero }
  let(:level_0_targets) { create :target_group, milestone: true, level: level_0 }
  let!(:screening_target) { create :target, :admissions_screening, target_group: level_0_targets }

  include UserSpecHelper

  context 'user is already signed in as founder', js: true do
    before do
      startup.founders << founder
      sign_in_user founder.user
    end

    scenario 'user visits the apply page' do
      visit apply_path
      expect(page).to have_text('You have already completed registration.')
      expect(page).to have_link('Go to Dashboard')
    end
  end

  context 'user is a new visitor' do
    scenario 'user registers as a founder', js: true do
      visit apply_path
      expect(page).to have_text('Are you a registered founder?')
      expect(page).to have_link('Sign In to Continue')

      # fill in the registration form
      expect(page).to have_text('Apply Now')
      fill_in 'founders_registration_name', with: 'Jack Sparrow'
      fill_in 'founders_registration_email', with: 'elcapitan@sv.co'
      fill_in 'founders_registration_email_confirmation', with: 'elcapitan@sv.co'
      fill_in 'founders_registration_phone', with: '9876543210'
      select "My college isn't listed", from: 'founders_registration_college_id'
      fill_in 'founders_registration_college_text', with: 'Swash Bucklers Training Institute'

      click_on 'Submit'

      # founder must have reached his new dashboard with the tour triggere
      expect(page).to have_text('Welcome to your personal dashboard!')
    end
  end
end
