require 'rails_helper'

feature 'User signing in by supplying email address' do
  context 'when a user exists' do
    let(:user) { create :user }

    context "when the user hasn't signed in recently" do
      scenario 'user is sent an email with sign in link' do
        visit new_user_session_url

        fill_in 'user_sign_in[email]', with: user.email
        click_button 'Email me a link to sign in'

        expect(page).to have_content('An email with a Sign-in link has been sent to your address.')
      end

      scenario 'bots are blocked from signing in' do
        visit new_user_session_url

        fill_in 'user_sign_in[email]', with: user.email
        fill_in 'user_sign_in[username]', with: 'stupid_bot'
        click_button 'Email me a link to sign in'

        expect(page).to have_content('Your request has been blocked because it is suspicious.')
      end
    end

    context 'when the user signed in less that two minutes ago' do
      scenario 'user is blocked from repeat attempts to send sign in email' do
        visit new_user_session_url

        fill_in 'user_sign_in[email]', with: user.email
        click_button 'Email me a link to sign in'

        expect(page).to have_content('An email with a Sign-in link has been sent to your address.')

        visit new_user_session_url

        fill_in 'user_sign_in[email]', with: user.email
        click_button 'Email me a link to sign in'

        expect(page).to have_content('An email was sent less than two minutes ago.')
        expect(page).to have_content('Please wait for a few minutes before trying again.')
      end
    end
  end

  context 'when user does not exist' do
    scenario 'responds with an error message' do
      visit new_user_session_url

      expect(page).to have_content('Sign in with your PupilFirst ID')

      fill_in 'user_sign_in[email]', with: 'unregistered@example.org'

      click_button 'Email me a link to sign in'

      expect(page).to have_content('Please check the email that you entered.')
      expect(page).to have_content('Could not find user with this email.')
    end
  end
end
