require "rails_helper"

feature "User signing in by supplying email address", js: true do
  include HtmlSanitizerSpecHelper

  let!(:school) { create :school, :current }

  context "when a user exists" do
    let(:user) { create :user }

    scenario "user signs in by typing verification code sent via email" do
      visit new_user_session_path

      fill_in "Email address", with: user.email
      click_button "Continue with email"

      expect(page).to have_content(
        "We've sent a verification code to #{user.email}"
      )

      # Check email.
      open_email(user.email)
      expect(current_email.subject).to eq("Sign into #{school.name}")

      # Extract the verification code.
      verification_code = current_email.body.match(/(\d{6})/)[1]

      fill_in "Verification Code", with: verification_code
      click_button "Verify code"

      expect(page).to have_content(user.name)
      expect(page).to have_link("Edit Profile")
    end

    scenario "user signs in by clicking the one-time link sent via email" do
      visit new_user_session_path

      fill_in "Email address", with: user.email
      click_button "Continue with email"

      expect(page).to have_content(
        "We've sent a verification code to #{user.email}"
      )

      expect(page).to have_content(
        "We've included a one-time link in the email"
      )

      # Check email.
      open_email(user.email)
      expect(current_email.subject).to eq("Sign into #{school.name}")

      # Click the link.
      current_email.click_link("Sign in")

      expect(page).to have_content(user.name)
      expect(page).to have_link("Edit Profile")
    end

    scenario "user is blocked from repeated attempts to request a sign-in email" do
      visit new_user_session_path

      fill_in "Email address", with: user.email
      click_button "Continue with email"

      expect(page).to have_content("We've sent a verification code")

      # Check email.
      open_email(user.email)
      expect(current_email.subject).to eq("Sign into #{school.name}")

      # Reload the page.
      visit new_user_session_path

      fill_in "Email address", with: user.email
      click_button "Continue with email"

      # It'll say that we've sent an email...
      expect(page).to have_content("We've sent a verification code")

      # ...but no additional email should have been sent.
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    scenario "user resets their password and is blocked from repeat attempts to send reset password email" do
      visit new_user_session_path

      click_link "Sign in using your password"
      click_link "Reset Your Password"
      fill_in "Email", with: user.email
      click_button "Request password reset"

      expect(page).to have_content(
        "We've sent you a link to reset your password"
      )

      open_email(user.email)

      expect(sanitize_html(current_email.body)).to include(
        "https://test.host/users/reset_password?token="
      )

      # Trying to reset password again should not send another email.
      visit new_user_session_path
      click_link "Sign in using your password"
      click_link "Reset Your Password"
      fill_in "Email", with: user.email
      click_button "Request password reset"

      expect(page).to have_content(
        "We've sent you a link to reset your password"
      )

      # Confirm that no additional email is sent.
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    context "when user visits the reset password page" do
      let(:password) { Faker::Internet.password }
      let(:course) { create :course }
      let(:level) { create :level, :one, course: course }
      let(:cohort) { create :cohort, course: course }

      before { create :student, user: user, cohort: cohort }

      scenario "user changes password with a valid token" do
        user.regenerate_reset_password_token

        user.update!(reset_password_sent_at: Time.zone.now)
        visit reset_password_path(token: user.original_reset_password_token)

        fill_in "New Password", with: "password123"
        fill_in "Confirm Password", with: "password123"

        expect(page).to have_text(
          "Add another word or two. Uncommon words are better."
        )

        expect(page).to have_text("Weak")

        fill_in "New Password", with: password
        fill_in "Confirm Password", with: password
        click_button "Update Password"
        expect(page).to have_content(user.students.first.course.name)
        expect(user.reload.reset_password_token).to eq(nil)

        # Let's try signing in.
        click_button "Show user controls"
        click_link "Sign Out"

        expect(page).to have_content(school.name)

        # Try signing in with an invalid password, and then with the newly set correct password.
        click_link "Sign In"
        click_link "Sign in using your password"
        fill_in "Email address", with: user.email
        fill_in "Password", with: "incorrect password"
        click_button "Sign in with password"

        expect(
          page
        ).to have_text "The supplied email address and password do not match"

        # Let's try using the enter key instead.
        fill_in "Email address", with: user.email
        fill_in "Password", with: password + "\n"

        expect(page).to have_content(user.students.first.course.name)
      end

      scenario "user cannot change password without a valid token" do
        visit reset_password_path(token: "a-random-token")

        expect(page).to have_content(
          "That one-time link has already been used, or is invalid"
        )
      end
    end
  end

  scenario "user attempts to sign in with an unregistered email address" do
    visit new_user_session_path

    fill_in "Email address", with: "unregistered@example.org"
    click_button "Continue with email"

    expect(page).to have_content(
      "We've sent a verification email to unregistered@example.org"
    )

    expect(ActionMailer::Base.deliveries.count).to eq(0)
  end

  scenario "user attempts to reset password of an unregistered email address" do
    visit new_user_session_path

    click_link "Continue with email"
    click_link "Reset Your Password"
    fill_in "Email", with: "unregistered@example.org"
    click_button "Request password reset"

    expect(page).to have_content(
      "If your email address is associated with an account, you'll find instructions to set a new password in your inbox"
    )

    expect(ActionMailer::Base.deliveries.count).to eq(0)
  end
end
