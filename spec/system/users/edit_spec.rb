require "rails_helper"

feature "User Edit", js: true do
  include UserSpecHelper
  include NotificationHelper
  include HtmlSanitizerSpecHelper

  let(:student) { create :student }
  let(:user) { student.user }
  let(:student_name) { Faker::Name.name }
  let(:preferred_name) { Faker::Name.name }
  let(:about) { Faker::Lorem.paragraphs.join(" ") }
  let(:current_password) do
    Faker::Internet.password(min_length: 8, max_length: 16)
  end
  let(:new_password) { Faker::Internet.password(min_length: 8, max_length: 16) }

  def upload_path(file)
    File.absolute_path(Rails.root.join("spec", "support", "uploads", file))
  end

  scenario "User tries to submit a blank form" do
    sign_in_user(user, referrer: edit_user_path)

    expect(page).to have_text("Edit your profile")

    fill_in "user_name", with: ""

    expect(page).to have_content("Name can't be blank")
  end

  scenario "User fills in all fields and submits" do
    sign_in_user(user, referrer: edit_user_path)
    expect(page).to have_text("Edit").and have_text("profile")

    fill_in "user_name", with: student_name
    attach_file "user-edit__avatar-input",
                upload_path("faculty/donald_duck.jpg"),
                visible: false
    dismiss_notification
    fill_in "about", with: about
    find("span", text: "Send me a daily email").click
    click_button "Save Changes"

    expect(page).to have_text("Profile updated successfully!")

    dismiss_notification

    # Confirm that student has, indeed, been updated.
    expect(student.reload).to have_attributes(name: student_name, about: about)

    expect(student.avatar.filename).to eq("donald_duck.jpg")
    expect(user.reload.preferences["daily_digest"]).to eq(true)
  end

  context "when user updates name" do
    let(:new_name) { Faker::Name.name }
    let(:old_name) { user.name }

    it "creates an audit record" do
      sign_in_user(user, referrer: edit_user_path)
      fill_in "user_name", with: new_name
      click_button "Save Changes"

      expect(page).to have_text("Profile updated successfully!")

      audit_record = AuditRecord.last
      metadata = audit_record.metadata

      expect(audit_record.audit_type).to eq(
        AuditRecord.audit_types[:update_name]
      )

      expect(audit_record.school_id).to eq(user.school_id)
      expect(metadata["user_id"]).to eq(user.id)
      expect(metadata["old_name"]).to eq(old_name)
      expect(metadata["new_name"]).to eq(new_name)
    end
  end

  scenario "User update the preferred name" do
    sign_in_user(user, referrer: edit_user_path)
    expect(page).to have_text("Edit").and have_text("profile")

    fill_in "preferred_name", with: preferred_name
    click_button "Save Changes"

    expect(page).to have_text("Profile updated successfully!")
    expect(user.reload).to have_attributes(preferred_name: preferred_name)

    visit(dashboard_path)

    expect(page).to have_text(preferred_name)
  end

  scenario "User sets a new password" do
    sign_in_user(user, referrer: edit_user_path)

    expect(page).to have_text("Set up password")
    expect(user.encrypted_password).to be_blank

    expect(page).to have_no_field("Current password")
    expect(page).to have_no_field("New password")

    click_button "Set password"

    dismiss_notification

    # Check email for password reset.
    open_email(user.email)
    expect(sanitize_html(current_email.body)).to include(
      "https://test.host/users/reset_password?token="
    )
  end

  scenario "user changes the language" do
    sign_in_user(user, referrer: edit_user_path)
    expect(page).to have_text("Localization")

    select "Russian - русский", from: "Language"
    click_button "Save Changes"

    expect(page).to have_text("Profile updated successfully!")

    visit(dashboard_path)

    expect(page).to have_text("Мои Курсы")
  end

  context "when the user has a password set" do
    before do
      user.password = current_password
      user.password_confirmation = current_password
      user.save!
    end

    scenario "user changes password" do
      sign_in_user(user, referrer: edit_user_path)

      expect(page).to have_text("Change your current password")

      # Check a failure path.
      fill_in "Current password", with: "not the current password"
      fill_in "New password", with: "long_enough"
      fill_in "Confirm password", with: "long_enough"

      expect(page).to have_text(
        "Add another word or two. Uncommon words are better."
      )
      expect(page).to have_text("Fair")

      click_button "Save Changes"

      expect(page).to have_text("Current password is incorrect")
      dismiss_notification

      expect(user.reload.valid_password?(current_password)).to eq(true)

      # Check success path.
      fill_in "Current password", with: current_password
      fill_in "New password", with: new_password
      fill_in "Confirm password", with: new_password

      click_button "Save Changes"

      expect(page).to have_text("Profile updated successfully!")
      expect(user.reload.valid_password?(new_password)).to eq(true)
    end

    scenario "user forgets her current password and changes using reset password" do
      sign_in_user(user, referrer: edit_user_path)

      expect(page).to have_text("Forgot your password?")

      click_button "Reset password"

      dismiss_notification

      # Check email for password reset.

      open_email(user.email)
      expect(sanitize_html(current_email.body)).to include(
        "https://test.host/users/reset_password?token="
      )
    end
  end
end
