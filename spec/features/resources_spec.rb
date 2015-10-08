require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Resources' do
  let(:user) { create :user_with_password, confirmed_at: Time.now }

  before :all do
    WebMock.allow_net_connect!
  end

  before :each do
    # Login the user.
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password'
    click_on 'Sign in'
  end

  after :all do
    WebMock.disable_net_connect!
  end

  scenario 'Founder visits resources page'

  scenario 'Founder visits specific resource page'

  scenario 'Founder downloads resource'
end
