require 'rails_helper'

feature 'Referrer Spec', js: true do
  let!(:school) { create :school, :current }
  let(:user) { create :user, :with_password, school: school }
  let!(:school_admin) { create :school_admin, user: user }

  scenario 'user will be redirected to the last known location upon login with password' do
    visit school_path

    click_button 'Continue with email'
    fill_in 'email', with: user.email
    fill_in 'password', with: user.password
    click_button 'Sign in with password'

    expect(page).to have_current_path(school_path)
  end

  scenario 'user will be redirected to referrer path when referrer is set' do
    visit new_user_session_path referrer: school_path

    click_button 'Continue with email'
    fill_in 'email', with: user.email
    fill_in 'password', with: user.password
    click_button 'Sign in with password'

    expect(page).to have_current_path(school_path)
  end

  scenario 'referrer will be set for login with token when the last location is known' do
    visit school_path

    click_button 'Continue with email'
    fill_in 'Email Address', with: user.email
    click_button 'Email me a link to sign in'

    expect(page).to have_content("We've sent you a magic link!")

    open_email(user.email)
    link = current_email.body.match(/href="(?<url>.+?)">/)[:url]
    expect(CGI::parse(URI::parse(link).query)["referrer"]).to have_content(["/school"])
  end
end
