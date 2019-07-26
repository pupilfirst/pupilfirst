require 'rails_helper'

feature 'User signing in by supplying email address' do
  scenario 'user visits PupilFirst sign in page' do
    visit new_user_session_url

    # App should raise not_found
    expect(page).to have_http_status(404)
  end
end
