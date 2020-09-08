require 'rails_helper'

feature 'User Delete Account' do
  include UserSpecHelper
  include NotificationHelper
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create :user }
  let(:admin_user) { create :user, school: user.school }
  let!(:school_admin) { create :school_admin, user: admin_user, school: admin_user.school }

  context 'user is a not an admin' do
    scenario 'user initiates account deletion', js: true do
      sign_in_user(user, referrer: edit_user_path)

      expect(page).to have_text('Delete account')

      click_button 'Delete your account'

      expect(page).to have_text('Are you sure you want to delete your account?')

      within("div[aria-label='Confirm dialog for account deletion']") do
        fill_in 'email', with: user.email
      end

      current_delete_token = user.delete_account_token

      click_button 'Initiate Deletion'

      expect(page).to have_text('Check your inbox for further steps', wait: 10)
      dismiss_notification

      expect(user.reload.delete_account_token).to_not eq(current_delete_token)
      open_email(user.email)

      subject = current_email.subject
      expect(subject).to include("Delete account from #{user.school.name}")

      body = current_email.body
      expect(body).to include("Please click the link above to confirm account deletion")
      expect(body).to include("https://test.host/users/delete_account?token=#{user.delete_account_token_original}")
    end

    scenario 'user visits the user edit page with an already valid delete token', js: true do
      user.regenerate_delete_account_token
      user.update!(delete_account_sent_at: 25.minutes.ago)

      sign_in_user(user, referrer: edit_user_path)

      expect(page).to have_text('You have already initiated account deletion. Please check your inbox for further steps to delete your account')
      expect(page).to_not have_button('Delete Account')
    end

    scenario 'user visits the delete account page with valid token', js: true do
      user.regenerate_delete_account_token
      user.update!(delete_account_sent_at: 20.minutes.ago)
      visit delete_account_path(token: user.delete_account_token_original)

      expect(page).to have_text("We're sorry to see you go")

      click_button('Delete Account')

      expect(page).to have_text("Account deletion is in progress", wait: 10)

      expect(page).to have_link(href: "/users/sign_in", wait: 10)

      open_email(user.email)
      subject = current_email.subject
      expect(subject).to include("Account deleted successfully from #{user.school.name}")

      body = current_email.body
      expect(body).to include("Account Deleted Successfully")
      expect(body).to include("Your account in #{user.school.name} has been successfully deleted.")

      # Check audit records
      audit_record = AuditRecord.last
      expect(audit_record.audit_type).to eq(AuditRecord::TYPE_DELETE_ACCOUNT)
      expect(audit_record.school_id).to eq(user.school_id)
      expect(audit_record.metadata['email']).to eq(user.email)
    end

    scenario 'user visits the delete account page with invalid token', js: true do
      sign_in_user(user, referrer: delete_account_path(token: 'test_token'))

      expect(page).to have_text("That link has expired or is invalid. Please try again")
    end

    scenario 'user visits the delete account page with an expired token', js: true do
      user.regenerate_delete_account_token
      user.update!(delete_account_sent_at: Time.zone.now)

      travel_to 35.minutes.from_now do
        visit delete_account_path(token: user.delete_account_token_original)

        expect(page).to have_text('That link has expired or is invalid')
      end
    end
  end

  context 'user is a school admin' do
    scenario 'user visits user edit page to delete account', js: true do
      sign_in_user(admin_user, referrer: edit_user_path)

      expect(page).to have_text('You are currently an admin of this school. Please delete your admin access to enable account deletion')
      expect(page).to_not have_button('Delete Account')
    end
  end
end
