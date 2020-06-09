require 'rails_helper'

feature 'User Delete Account' do
  include UserSpecHelper
  include NotificationHelper

  let(:user) { create :user }
  let(:admin_user) { create :user, school: user.school }
  let!(:school_admin) { create :school_admin, user: admin_user, school: admin_user.school }
  let(:user_password) { Faker::Internet.password(min_length: 8, max_length: 16) }
  let(:admin_user_password) { Faker::Internet.password(min_length: 8, max_length: 16) }

  context 'user is a not an admin' do
    before do
      user.password = user_password
      user.password_confirmation = user_password
      user.save!
    end

    scenario 'user initiates account deletion', js: true do
      sign_in_user(user, referer: edit_user_path)

      expect(page).to have_text('Delete account')

      click_button 'Delete your account'

      expect(page).to have_text('Are you sure you want to delete your account?')

      within("div[aria-label='Confirm dialog for account deletion']") do
        fill_in 'password', with: user_password
      end

      current_delete_token = user.delete_account_token

      click_button 'Confirm Deletion'

      expect(page).to have_text('Check your inbox for further steps', wait: 10)
      dismiss_notification

      expect(user.reload.delete_account_token).to_not eq(current_delete_token)
      open_email(user.email)

      subject = current_email.subject
      expect(subject).to include("Delete account from #{user.school.name}")

      body = current_email.body
      expect(body).to include("Please click the link above to confirm account deletion")
      expect(body).to include("https://test.host/users/delete_account?token=#{user.delete_account_token}")
    end

    scenario 'user visits the delete account page with valid token', js: true do
      user.regenerate_delete_account_token
      user.update!(delete_account_sent_at: 20.minutes.ago)
      sign_in_user(user, referer: delete_account_path(token: user.delete_account_token))

      expect(page).to have_text("We're sorry to see you go")

      click_button('Delete Account')

      expect(page).to have_text("Account deletion initated successfully. This might take a few minutes. You will be notified over email once complete", wait: 10)

      expect(page).to have_link(href: "/users/sign_in", wait: 5)

      open_email(user.email)
      subject = current_email.subject
      expect(subject).to include("Account deleted successfully from #{user.school.name}")

      body = current_email.body
      expect(body).to include("Account Deleted Successfully")
      expect(body).to include("Your request to delete account in #{user.school.name} has been successfully processed.")
    end

    scenario 'user visits the delete account page with invalid token', js: true do
      sign_in_user(user, referer: delete_account_path(token: 'test_token'))

      expect(page).to have_text("That link has expired or is invalid. Please try again")
    end

    scenario 'visits delete account link without signing in', js: true do
      user.regenerate_delete_account_token
      visit delete_account_path(token: user.delete_account_token)

      expect(page).to have_text("Please sign in to continue")
    end
  end

  context 'user is a school admin' do
    before do
      admin_user.password = admin_user_password
      admin_user.password_confirmation = admin_user_password
      admin_user.save!
    end

    scenario 'user attempts to delete account', js: true do
      sign_in_user(admin_user, referer: edit_user_path)

      expect(page).to have_text('Delete account')

      click_button 'Delete your account'

      expect(page).to have_text('Are you sure you want to delete your account?')

      within("div[aria-label='Confirm dialog for account deletion']") do
        fill_in 'password', with: admin_user_password
      end

      click_button 'Confirm Deletion'

      expect(page).to have_text('admin rights in school not revoked', wait: 10)
      dismiss_notification
    end
  end
end
