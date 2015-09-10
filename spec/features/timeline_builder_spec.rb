require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Timeline Builder' do
  let(:user) { create :user_with_password, confirmed_at: Time.now }
  let(:startup) { create :startup }

  before :all do
    WebMock.allow_net_connect!
  end

  before :each do
    # Add user as founder of startup.
    startup.founders << user

    # Log in the user.
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password'
    click_on 'Sign in'
  end

  context 'Founder visits Timeline page of verified startup' do
    scenario 'Founder submits new timeline event', js: true do
      visit startup_path(startup)
    end
  end

  after :all do
    WebMock.disable_net_connect!
  end
end
