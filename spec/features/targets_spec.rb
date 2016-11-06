require 'rails_helper'

feature 'Targets spec' do
  let(:founder) { create :founder, confirmed_at: Time.now }
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
      # Log in the founder.
      visit user_token_path(token: founder.user.login_token)

      expect(page).to have_selector('.pending-count', text: '1')
    end
  end
end
