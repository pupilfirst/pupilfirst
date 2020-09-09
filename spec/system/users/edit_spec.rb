require 'rails_helper'

feature 'User Edit' do
  include UserSpecHelper
  include NotificationHelper

  let(:startup) { create :startup }
  let(:student) { create :founder }
  let(:user) { student.user }
  let(:student_name) { Faker::Name.name }
  let(:about) { Faker::Lorem.paragraphs.join(' ') }
  let(:current_password) { Faker::Internet.password(min_length: 8, max_length: 16) }
  let(:new_password) { Faker::Internet.password(min_length: 8, max_length: 16) }

  def upload_path(file)
    File.absolute_path(Rails.root.join('spec', 'support', 'uploads', file))
  end

  before do
    startup.founders << student
  end

  scenario 'User tries to submit a blank form', js: true do
    sign_in_user(user, referrer: edit_user_path)

    expect(page).to have_text('Edit your profile')

    fill_in 'user_name', with: ''

    expect(page).to have_content("Name can't be blank")
  end

  scenario 'User fills in all fields and submits', js: true do
    sign_in_user(user, referrer: edit_user_path)
    expect(page).to have_text('Edit').and have_text('profile')

    fill_in 'user_name', with: student_name
    attach_file 'user-edit__avatar-input', upload_path('faculty/donald_duck.jpg'), visible: false
    dismiss_notification
    fill_in 'about', with: about
    find('span', text: 'Send me a daily email').click
    click_button 'Save Changes'

    expect(page).to have_text('Profile updated successfully!')

    dismiss_notification

    # Confirm that student has, indeed, been updated.
    expect(student.reload).to have_attributes(
      name: student_name,
      about: about,
    )

    expect(student.avatar.filename).to eq('donald_duck.jpg')
    expect(user.reload.preferences['daily_digest']).to eq(true)
  end

  scenario 'User sets a new password', js: true do
    sign_in_user(user, referrer: edit_user_path)

    expect(page).to have_text('Set password for your account')
    expect(user.encrypted_password).to be_blank

    # Check a failure path.
    fill_in 'New password', with: 'short'
    fill_in 'Confirm password', with: 'short'

    expect(page).to have_text('New password and confirmation should match and must have atleast 8 characters')

    fill_in 'New password', with: 'long_enough'
    fill_in 'Confirm password', with: 'but_not_the_same'

    expect(page).to have_text('New password and confirmation should match and must have atleast 8 characters')

    # Check basic success.
    fill_in 'New password', with: new_password
    fill_in 'Confirm password', with: new_password

    click_button 'Save Changes'

    expect(page).to have_text('Profile updated successfully!')
    expect(user.reload.valid_password?(new_password)).to eq(true)
  end

  context 'when the user has a password set' do
    before do
      user.password = current_password
      user.password_confirmation = current_password
      user.save!
    end

    scenario 'user changes her password', js: true do
      sign_in_user(user, referrer: edit_user_path)

      expect(page).to have_text('Change your current password')

      # Check a failure path.
      fill_in 'Current password', with: 'not the current password'
      fill_in 'New password', with: 'long_enough'
      fill_in 'Confirm password', with: 'long_enough'

      click_button 'Save Changes'

      expect(page).to have_text('Current password is incorrect')
      dismiss_notification

      expect(user.reload.valid_password?(current_password)).to eq(true)

      # Check success path.
      fill_in 'Current password', with: current_password
      fill_in 'New password', with: new_password
      fill_in 'Confirm password', with: new_password

      click_button 'Save Changes'

      expect(page).to have_text('Profile updated successfully!')
      expect(user.reload.valid_password?(new_password)).to eq(true)
    end
  end
end
