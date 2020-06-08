require 'rails_helper'

feature 'User Delete Account' do
  include UserSpecHelper
  include NotificationHelper

  let(:user) { create :user }
  let(:admin_user) { create :user, school: user.school }
  let(:school_admin) { create :school_admin, user: admin_user, school: school }
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

      click_button 'Confirm Deletion'

      expect(page).to have_text('Check your inbox for further steps')
      dismiss_notification

      expect(user.delete_account_token).to_not eq(nil)
      open_email(user.email)

      subject = current_email.subject
      expect(subject).to include("Please click the link above to confirm account deletion")

      body = sanitize_html(current_email.body)
      expect(body).to include("Delete Account from #{user.school.name}")
      expect(body).to include(user.delete_account_token)
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

      expect(page).to have_text('admin rights in school not revoked')
      dismiss_notification
    end
  end
end
