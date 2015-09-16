require 'rails_helper'

feature 'Startup Edit' do
  let(:user) { create :user_with_password, confirmed_at: Time.now }
  let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED }

  before :each do
    # Add user as founder of startup.
    startup.founders << user

    # Log in the user.
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password'
    click_on 'Sign in'
    visit edit_user_startup_path(user)

    # User should now be on his startup edit page.
  end

  context 'Founder visits edit page of his startup' do
    scenario 'Founder stares at edit page' do
      expect(page).to have_text('Edit your startup profile')
    end
  end

end
