require 'rails_helper'

feature 'Select Sign-in available options based on Devise capabilities', js: true do
  let!(:school) { create :school, :current }

  scenario 'show only available federated sign-ins' do
    allow_any_instance_of(Users::Sessions::NewPresenter).to receive(:providers).and_return([:keycloak_openid, :github])
    visit new_user_session_path

    expect(page).to have_content('Continue with Keycloak')
    expect(page).to have_content('Continue with Github')
    expect(page).not_to have_content('Continue with Google')
    expect(page).not_to have_content('Continue with Facebook')
  end

  scenario 'dont have sign-in by email' do
    allow(ENV).to receive(:fetch).with('ONLY_KEYCLOAK')
      .and_return(false)
    allow(ENV).to receive(:fetch).with('ALLOW_EMAIL_SIGN_IN')
      .and_return(false)
    visit new_user_session_path
    expect(page).not_to have_content('Continue with email')
  end

  scenario 'allow sign-in by email' do
    allow(ENV).to receive(:fetch).with('ONLY_KEYCLOAK')
      .and_return(false)
    allow(ENV).to receive(:fetch).with('ALLOW_EMAIL_SIGN_IN')
      .and_return(true)
    visit new_user_session_path
    expect(page).to have_content('Continue with email')
  end
end
