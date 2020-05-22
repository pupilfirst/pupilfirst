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

  scenario 'User tries to submit a blank form' do
    sign_in_user(user, referer: edit_user_path)

    expect(page).to have_text('Edit your profile')

    fill_in 'users_edit_name', with: ''
    click_button 'Save Changes'

    expect(page).to have_content("Name can't be blank")
  end

  scenario 'User fills in all fields and submits', js: true do
    sign_in_user(user, referer: edit_user_path)
    expect(page).to have_text('Edit').and have_text('profile')

    fill_in 'users_edit_name', with: student_name
    attach_file 'Avatar', upload_path('faculty/donald_duck.jpg'), visible: false
    fill_in 'users_edit_about', with: about
    select 'Send me a daily email', from: 'Community Digest'
    click_button 'Save Changes'

    expect(page).to have_text('Your profile has been updated')

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
    sign_in_user(user, referer: edit_user_path)

    expect(page).to have_text('Set a password for signing in')

    # Check a failure path.
    fill_in 'New Password', with: 'short'
    fill_in 'Confirm your New Password', with: 'short'

    click_button 'Save Changes'

    expect(page).to have_text('New password should be at least 8 characters long')
    expect(user.reload.encrypted_password).to be_blank

    fill_in 'New Password', with: 'long_enough'
    fill_in 'Confirm your New Password', with: 'but_not_the_same'

    click_button 'Save Changes'

    expect(page).to have_text('New password confirmation does not match')
    expect(user.reload.encrypted_password).to be_blank

    # Check basic success.
    fill_in 'New Password', with: new_password
    fill_in 'Confirm your New Password', with: new_password

    click_button 'Save Changes'

    expect(page).to have_text('Your profile has been updated')
    expect(user.reload.valid_password?(new_password)).to eq(true)
  end

  context 'when the user has a password set' do
    before do
      user.password = current_password
      user.password_confirmation = current_password
      user.save!
    end

    scenario 'user changes her password', js: true do
      sign_in_user(user, referer: edit_user_path)

      expect(page).to have_text('Change your current password')

      # Check a failure path.
      fill_in 'Current Password', with: 'not the current password'
      fill_in 'New Password', with: 'long_enough'
      fill_in 'Confirm your New Password', with: 'long_enough'

      click_button 'Save Changes'

      expect(page).to have_text('Current password is incorrect')
      expect(user.reload.valid_password?(current_password)).to eq(true)

      # Check success path.
      fill_in 'Current Password', with: current_password
      fill_in 'New Password', with: new_password
      fill_in 'Confirm your New Password', with: new_password

      click_button 'Save Changes'

      expect(page).to have_text('Your profile has been updated')
      expect(user.reload.valid_password?(new_password)).to eq(true)
    end
  end
end
