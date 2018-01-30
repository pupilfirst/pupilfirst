require 'rails_helper'

feature 'Founder Registration' do
  include UserSpecHelper

  let!(:level_0) { create :level, :zero }
  let(:level_0_targets) { create :target_group, milestone: true, level: level_0 }
  let!(:screening_target) { create :target, :admissions_screening, target_group: level_0_targets }
  let!(:fee_payment_target) { create :target, :admissions_fee_payment, target_group: level_0_targets }

  context 'User is already a founder' do
    let(:startup) { create :level_0_startup }
    let(:founder) { startup.team_lead }

    scenario 'User is blocked from registering again', js: true do
      visit apply_path

      expect(page).to have_selector('#new_founders_registration')

      fill_in 'founders_registration_name', with: founder.name
      fill_in 'founders_registration_email', with: founder.email
      # fill_in 'founders_registration_email_confirmation', with: founder.email
      fill_in 'founders_registration_phone', with: founder.phone
      select "My college isn't listed", from: 'founders_registration_college_id'
      fill_in 'founders_registration_college_text', with: founder.college.name

      click_button 'Apply'

      expect(page).to have_content('You have already completed this step. Please sign in instead.')
    end

    scenario 'Signed-in user visits the join page' do
      sign_in_user founder.user, referer: apply_path
      expect(page).to have_text('You have already completed registration.')
      expect(page).to have_link('Go to Dashboard')
      expect(page).not_to have_selector('#new_founders_registration')
    end
  end

  context 'User is a new visitor' do
    scenario 'User registers as a founder', js: true do
      visit apply_path

      # Fill in the registration form.
      expect(page).to have_button('Apply')
      fill_in 'founders_registration_name', with: 'Jack Sparrow'
      fill_in 'founders_registration_email', with: 'elcapitan@sv.co'
      # fill_in 'founders_registration_email_confirmation', with: 'elcapitan@sv.co'
      fill_in 'founders_registration_phone', with: '9876543210'
      select "My college isn't listed", from: 'founders_registration_college_id'
      fill_in 'founders_registration_college_text', with: 'Swash Bucklers Training Institute'

      click_button 'Apply'

      # Founder must have reached his new dashboard with the tour triggered.
      expect(page).to have_text("Team Target:#{screening_target.title}")

      last_founder = Founder.last

      expect(last_founder.startup).to be_present
      expect(last_founder.name).to eq('Jack Sparrow')
      expect(last_founder.email).to eq('elcapitan@sv.co')
      expect(last_founder.phone).to eq('9876543210')
      expect(last_founder.college_text).to eq('Swash Bucklers Training Institute')
    end
  end

  context 'User is a new visitor and makes a possible mistake in the email' do
    before do
      visit apply_path

      # Fill in the registration form.
      fill_in 'founders_registration_name', with: 'Jack Sparrow'
      fill_in 'founders_registration_email', with: 'test@gamil.com'
      fill_in 'founders_registration_phone', with: '9876543210'
      select "My college isn't listed", from: 'founders_registration_college_id'
      fill_in 'founders_registration_college_text', with: 'Swash Bucklers Training Institute'

      click_button 'Apply'
    end

    scenario 'User accepts the email hint', js: true do
      expect(page).to have_text('Did you mean test@gmail.com?')
      click_on 'Yes'
      click_button 'Apply'

      expect(page).to have_text("Team Target:#{screening_target.title}")

      last_founder = Founder.last
      expect(last_founder.email).to eq('test@gmail.com')
    end

    scenario 'User rejects the email hint', js: true do
      expect(page).to have_text('Did you mean test@gmail.com?')
      click_on 'No'
      click_button 'Apply'

      expect(page).to have_text("Team Target:#{screening_target.title}")

      last_founder = Founder.last
      expect(last_founder.email).to eq('test@gamil.com')
    end
  end
end
