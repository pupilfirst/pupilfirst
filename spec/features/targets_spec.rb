require 'rails_helper'

feature 'Targets spec' do
  let(:target) { create :founder_with_password, confirmed_at: Time.now }
  let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED }

  let!(:target) { create :target, startup: startup, role: Target::ROLE_FOUNDER }

  before do
    # Add target as founder of startup.
    startup.founders << target
  end

  context 'target has verified timeline event for founder target' do
    let(:timeline_event) { create :timeline_event, target: target, startup: startup }

    before do
      timeline_event.verify!
      target.timeline_events << timeline_event
    end

    scenario 'target checks targets' do
      # Log in with target.
      visit new_founder_session_path
      fill_in 'target_email', with: target.email
      fill_in 'target_password', with: 'password'
      click_on 'Sign in'

      expect(page).to have_selector('.target-title', text: 'Done')
    end
  end

  context 'target does not have verified timeline event for founder target' do
    scenario 'target checks targets' do
      # Log in with target.
      visit new_founder_session_path
      fill_in 'target_email', with: target.email
      fill_in 'target_password', with: 'password'
      click_on 'Sign in'

      expect(page).to have_selector('.target-title', text: 'Pending')
    end
  end
end
