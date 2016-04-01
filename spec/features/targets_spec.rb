require 'rails_helper'

feature 'Targets spec' do
  let(:founder) { create :founder_with_password, confirmed_at: Time.now }
  let(:startup) { create :startup }
  let(:target) { create :target, assignee: founder, role: Target::ROLE_FOUNDER }

  before :each do
    # Add founder as founder of startup.
    startup.founders << founder

    # Memoize the target. Can't do this with a bang, because previous step needs to be completed.
    target
  end

  context 'founder does not have verified timeline event for founder target' do
    scenario 'founder checks targets' do
      # Log in with founder.
      visit new_founder_session_path
      fill_in 'founder_email', with: founder.email
      fill_in 'founder_password', with: 'password'
      click_on 'Sign in'

      expect(page).to have_selector('.pending-count', text: '1')
    end
  end
end
