require 'rails_helper'

feature 'Targets spec' do
  let(:founder) { create :founder_with_password, confirmed_at: Time.now }
  let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED }

  let!(:target) { create :target, startup: startup, role: Target::ROLE_FOUNDER }

  before do
    # Add founder as founder of startup.
    startup.founders << founder
  end

  # TODO: Re-write after completing new targets layout
  # context 'founder has verified timeline event for founder target' do
  #   let(:timeline_event) { create :timeline_event, founder: founder, startup: startup }
  #
  #   before do
  #     timeline_event.verify!
  #     target.timeline_events << timeline_event
  #   end
  #
  #   scenario 'founder checks targets' do
  #     # Log in with founder.
  #     visit new_founder_session_path
  #     fill_in 'founder_email', with: founder.email
  #     fill_in 'founder_password', with: 'password'
  #     click_on 'Sign in'
  #
  #     expect(page).to have_selector('.target-title', text: 'Done')
  #   end
  # end

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
