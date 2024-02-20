require "rails_helper"

feature "User signing in by supplying email address", js: true do
  include HtmlSanitizerSpecHelper

  let!(:school) { create :school, :current }

  context "when a user exists" do
    let(:user) { create :user }

    context "when the user hasn't signed in" do
      scenario "user can sign in with email" do
        visit new_user_session_path

        click_link "Continue with email"
        fill_in "Email Address", with: user.email
        click_button "Email me a link to sign in"

        expect(page).to have_content("We've sent you a magic link!")
      end
    end

    context "when the user requested a magic link less that two minutes ago" do
      scenario "user is blocked from repeat attempts to request magic link" do
        visit new_user_session_path

        click_link "Continue with email"
        fill_in "Email Address", with: user.email
        click_button "Email me a link to sign in"

        expect(page).to have_content("We've sent you a magic link!")

        # check email
        open_email(user.email)
        expect(current_email.subject).to eq("Log in to #{school.name}")

        click_link "Sign In"
        click_link "Continue with email"
        fill_in "Email Address", with: user.email
        click_button "Email me a link to sign in"

        expect(page).to have_content("We've sent you a magic link!")

        # Confirm no email is sent
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end

    context "when the user tries to reset password" do
      scenario "user is allowed to reset and blocked from repeat attempts to send reset password email" do
        visit new_user_session_path

        click_link "Continue with email"
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

        click_link "Sign In"
        click_link "Continue with email"
        click_link "Reset Your Password"
        fill_in "Email", with: user.email
        click_button "Request password reset"

        expect(page).to have_content(
          "We've sent you a link to reset your password"
        )

        # Confirm no email is sent
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end

    context "when user visits the reset password page" do
      let(:password) { Faker::Internet.password }
      let(:course) { create :course }
      let(:level) { create :level, :one, course: course }
      let(:cohort) { create :cohort, course: course }

      before { create :student, user: user, cohort: cohort }

      scenario "allow to change password with a valid token" do
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
        click_link "Continue with email"
        fill_in "Email Address", with: user.email
        fill_in "Password", with: "incorrect password"
        click_button "Sign in with password"

        expect(
          page
        ).to have_text "The supplied email address and password do not match"

        # Let's try using the enter key instead.
        fill_in "Email Address", with: user.email
        fill_in "Password", with: password + "\n"

        expect(page).to have_content(user.students.first.course.name)
      end

      scenario "does not allow to change password without a valid token" do
        visit reset_password_path(token: "myRandomToken")

        expect(page).to have_content(
          "That one-time link has already been used, or is invalid"
        )
      end
    end
  end

  context "when user does not exist" do
    scenario "Email me a link will responds with an error message" do
      visit new_user_session_path

      click_link "Continue with email"
      fill_in "Email Address", with: "unregistered@example.org"
      click_button "Email me a link to sign in"

      expect(page).to have_content(
        "If an account is associated with this email address, a one-time link will be sent"
      )
    end

    scenario "Reset password responds with an error message" do
      visit new_user_session_path

      click_link "Continue with email"
      click_link "Reset Your Password"
      fill_in "Email", with: "unregistered@example.org"
      click_button "Request password reset"

      expect(page).to have_content(
        "If your email address is associated with an account, you'll find instructions to set a new password in your inbox"
      )
    end
  end
end
