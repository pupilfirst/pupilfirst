require 'rails_helper'

feature 'Select Sign-in available options based on Devise capabilities', js: true do
  let!(:school) { create :school, :current }

  scenario 'show only available federated sign-ins' do
    allow(Devise).to receive(:omniauth_providers).and_return([:keycloak_openid, :github])
    visit new_user_session_path

    expect(page).to have_content('Continue with Keycloak')
    expect(page).to have_content('Continue with Github')
    expect(page).not_to have_content('Continue with Google')
    expect(page).not_to have_content('Continue with Facebook')
  end

  scenario 'dont have sign-in by email' do
    mock_props = {
      school_name: school.name,
      fqdn: page.current_host,
      available_oauth_providers: [],
      allow_email_sign_in: false
    }
    mock_presenter = double :presenter, props: mock_props
    allow(Users::Sessions::NewPresenter).to receive(:new).and_return(mock_presenter)
    visit new_user_session_path
    expect(page).not_to have_content('Continue with email')
  end
end
