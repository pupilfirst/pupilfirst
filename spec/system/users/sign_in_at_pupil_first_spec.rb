require 'rails_helper'

feature 'User signing in by supplying email address' do
  scenario 'user visits PupilFirst sign in page' do
    visit new_user_session_url

    # Customizations for PupilFirst should be visible.
    expect(page).to have_content('#360, 6th Main Road')
    expect(page).to have_content('support@pupilfirst.com')
  end
end
