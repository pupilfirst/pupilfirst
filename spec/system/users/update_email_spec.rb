require "rails_helper"

feature "User Update Email", js: true do
  include UserSpecHelper
  include NotificationHelper
  include ActiveSupport::Testing::TimeHelpers

  let(:school) { create :school, :current }
  let(:user_1) { create :user, school: school, password: "password" }
  let(:user_2) { create :user, school: school }
  let(:admin_user) { create :user, school: school }
  let!(:school_admin) do
    create :school_admin, user: admin_user, school: admin_user.school
  end
  let(:domain) { school.domains.where(primary: true).first }

  scenario "Send update email token when user update email" do
    sign_in_user(user_1, referrer: edit_user_path)
    expect(page).to have_text("Edit").and have_text("profile")

    click_button "Edit"
    fill_in "user_email", with: "testing@updateemail.com"
    click_button "Update"
    fill_in "password", with: "password"
    click_button "Update email"

    dismiss_notification

    expect(user_1.reload.new_email).to eq("testing@updateemail.com")
    expect(user_1.update_email_token).to be_present

    open_email("testing@updateemail.com")
    expect(current_email.subject).to eq(
      "Update your email address in #{school.name} school"
    )
    expect(current_email.body).to include(
      "https://#{domain.fqdn}/users/update_email?token="
    )
  end

  scenario "Error if user try to update to existing email" do
    sign_in_user(user_1, referrer: edit_user_path)
    expect(page).to have_text("Edit").and have_text("profile")

    click_button "Edit"
    fill_in "user_email", with: user_2.email
    click_button "Update"
    fill_in "password", with: "password"

    click_button "Update email"

    expect(page).to have_content(
      "This email is already associated with another user account."
    )

    expect(user_1.reload.new_email).to be_blank
  end

  scenario "User visits the update email link with valid token", js: true do
    sign_in_user(user_1)
    old_email = user_1.email
    new_email = "testing@updateemail.com"
    user_1.regenerate_update_email_token
    user_1.update!(
      new_email: new_email,
      update_email_token_sent_at: 20.minutes.ago
    )
    visit update_email_path(token: user_1.update_email_token)

    expect(user_1.reload.email).to eq(new_email)

    # Check for update email notification
    open_email(new_email)
    subject = current_email.subject
    expect(subject).to include(
      "Your email in #{school.name} school updated successfully"
    )

    body = current_email.body
    expect(body).to include(
      "Your email address in <strong>#{user_1.school.name}</strong> has been successfully updated from <strong>#{old_email}</strong> to <strong>#{new_email}</strong>."
    )

    # The original email address associated with the user account should also be notified.

    open_email(old_email)
    subject = current_email.subject
    expect(subject).to include(
      "Your email in #{school.name} school updated successfully"
    )

    body = current_email.body
    expect(body).to include(
      "Your email address in <strong>#{user_1.school.name}</strong> has been successfully updated from <strong>#{old_email}</strong> to <strong>#{new_email}</strong>."
    )

    # Check admin notification email
    open_email(school_admin.email)
    subject = current_email.subject
    expect(subject).to include("#{user_1.name} has changed email address.")

    body = current_email.body
    expect(body).to include(
      "<strong>#{user_1.name}</strong> from your school has updated the email address."
    )

    # Check audit records
    audit_record = AuditRecord.last
    expect(audit_record.audit_type).to eq(
      AuditRecord.audit_types[:update_email]
    )
    expect(audit_record.school_id).to eq(user_1.school_id)
    expect(audit_record.metadata["user_id"]).to eq(user_1.id)
    expect(audit_record.metadata["email"]).to eq(new_email)
    expect(audit_record.metadata["old_email"]).to eq(old_email)
  end

  scenario "user visits the update email link with invalid token", js: true do
    sign_in_user(user_1, referrer: update_email_path(token: "test_token"))

    expect(page).to have_text(
      "That link has expired or is invalid. Please try again"
    )
  end

  scenario "user visits the update email link with an expired token",
           js: true do
    sign_in_user(user_1)
    user_1.regenerate_update_email_token
    user_1.update!(update_email_token_sent_at: 20.minutes.ago)
    travel_to 35.minutes.from_now do
      visit update_email_path(token: user_1.update_email_token)

      expect(page).to have_text("That link has expired or is invalid")
    end
  end

  scenario "user attempts to update email without having an account password",
           js: true do
    # clear the user's password
    user_1.update!(encrypted_password: "")

    sign_in_user(user_1, referrer: edit_user_path)
    # expect disabled edit button with a notice
    expect(page).to have_button("Edit", disabled: true)
    expect(page).to have_text(
      "You must set a password before you can edit your account email address."
    )
  end
end
