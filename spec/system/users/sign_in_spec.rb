require 'rails_helper'

feature 'User signing in by supplying email address', js: true do
  let!(:school) { create :school, :current }

  context 'when a user exists' do
    let(:user) { create :user }

    context "when the user hasn't signed in" do
      scenario 'user can sign in with email' do
        visit new_user_session_path

        click_button 'Continue with email'
        fill_in 'Email Address', with: user.email
        click_button 'Email me a link to sign in'

        expect(page).to have_content("We've sent you a magic link!")
      end
    end

    context 'when the user signed in less that two minutes ago' do
      scenario 'user is blocked from repeat attempts to send sign in email' do
        visit new_user_session_path

        click_button 'Continue with email'
        fill_in 'Email Address', with: user.email
        click_button 'Email me a link to sign in'
        expect(page).to have_content("We've sent you a magic link!")
        click_link 'Sign In'
        click_button 'Continue with email'
        fill_in 'Email Address', with: user.email
        click_button 'Email me a link to sign in'
        expect(page).to have_content('An email was sent less than two minutes ago. Please wait for a few minutes before trying again')
      end
    end

    context 'when the user tries to reset password' do
      scenario 'user is allowed to reset and blocked from repeat attempts to send reset password email' do
        visit new_user_session_path

        click_button 'Continue with email'
        click_button 'Set a New Password'
        fill_in 'Email', with: user.email
        click_button 'Send Email'
        expect(page).to have_content("We've sent you a magic link!")
        click_link 'Sign In'
        click_button 'Continue with email'
        click_button 'Set a New Password'
        fill_in 'Email', with: user.email
        click_button 'Send Email'
        expect(page).to have_content('An email was sent less than two minutes ago. Please wait for a few minutes before trying again')
      end
    end

    context 'when user visits the reset password page' do
      let(:password) { Faker::Internet.password }

      before do
        create :founder, user: user
      end

      scenario 'allow to change password with a valid token' do
        user.regenerate_reset_password_token
        user.update!(reset_password_sent_at: Time.zone.now)
        visit reset_password_path(token: user.reset_password_token)

        fill_in 'New Password', with: password
        fill_in 'Confirm Password', with: password
        click_button 'Update Password'
        expect(page).to have_content(user.founders.first.course.name)
        expect(user.reload.reset_password_token).to eq(nil)

        # Let's try signing in.
        click_button "Show user controls"
        click_link "Sign Out"

        expect(page).to have_content(school.name)

        # Try signing in with an invalid password, and then with the newly set correct password.
        click_link 'Sign In'
        click_button 'Continue with email'
        fill_in 'Email Address', with: user.email
        fill_in 'Password', with: 'incorrect password'
        click_button "Sign in with password"

        expect(page).to have_text 'The supplied email address and password do not match'

        fill_in 'Password', with: password
        click_button "Sign in with password"

        expect(page).to have_content(user.founders.first.course.name)
      end

      scenario 'does not allow to change password without a valid token' do
        visit reset_password_path(token: "myRandomToken")
        expect(page).to have_content("That one-time link has already been used, or is invalid")
      end
    end
  end

  context 'when user does not exist' do
    scenario 'Email me a link will responds with an error message' do
      visit new_user_session_path

      click_button 'Continue with email'
      fill_in 'Email Address', with: 'unregistered@example.org'
      click_button 'Email me a link to sign in'
      expect(page).to have_content("Could not find user with this email. Please check the email that you entered")
    end

    scenario 'Reset password responds with an error message' do
      visit new_user_session_path

      click_button 'Continue with email'
      click_button 'Set a New Password'
      fill_in 'Email', with: 'unregistered@example.org'
      click_button 'Send Email'
      expect(page).to have_content("Could not find user with this email. Please check the email that you entered")
    end
  end
end
