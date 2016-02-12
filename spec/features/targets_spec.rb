require 'rails_helper'

feature 'Targets spec' do
  let(:user) { create :founder_with_password, confirmed_at: Time.now }
  let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED }

  let!(:target) { create :target, startup: startup, role: Target::ROLE_FOUNDER }

  before do
    # Add user as founder of startup.
    startup.founders << user
  end

  context 'User has verified timeline event for founder target' do
    let(:timeline_event) { create :timeline_event, user: user, startup: startup }

    before do
      timeline_event.verify!
      target.timeline_events << timeline_event
    end

    scenario 'User checks targets' do
      # Log in with user.
      visit new_founder_session_path
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'password'
      click_on 'Sign in'

      expect(page).to have_selector('.target-title', text: 'Done')
    end
  end

  context 'User does not have verified timeline event for founder target' do
    scenario 'User checks targets' do
      # Log in with user.
      visit new_founder_session_path
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'password'
      click_on 'Sign in'

      expect(page).to have_selector('.target-title', text: 'Pending')
    end
  end
end
