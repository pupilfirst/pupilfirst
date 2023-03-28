require 'rails_helper'

feature 'User Edit', js: true do
  include UserSpecHelper
  include NotificationHelper
  include ConfigHelper

  let(:student) { create :founder }
  let(:user) { student.user }
  let(:student_name) { Faker::Name.name }
  let(:preferred_name) { Faker::Name.name }
  let(:about) { Faker::Lorem.paragraphs.join(' ') }
  let(:current_password) do
    Faker::Internet.password(min_length: 8, max_length: 16)
  end
  let(:new_password) { Faker::Internet.password(min_length: 8, max_length: 16) }

  def upload_path(file)
    File.absolute_path(Rails.root.join('spec', 'support', 'uploads', file))
  end

  scenario 'User tries to submit a blank form' do
    sign_in_user(user, referrer: edit_user_path)

    expect(page).to have_text('Edit your profile')

    fill_in 'user_name', with: ''

    expect(page).to have_content("Name can't be blank")
  end

  scenario 'User fills in all fields and submits' do
    sign_in_user(user, referrer: edit_user_path)
    expect(page).to have_text('Edit').and have_text('profile')

    fill_in 'user_name', with: student_name
    attach_file 'user-edit__avatar-input',
                upload_path('faculty/donald_duck.jpg'),
                visible: false
    dismiss_notification
    fill_in 'about', with: about
    find('span', text: 'Send me a daily email').click
    click_button 'Save Changes'

    expect(page).to have_text('Profile updated successfully!')

    dismiss_notification

    # Confirm that student has, indeed, been updated.
    expect(student.reload).to have_attributes(name: student_name, about: about)

    expect(student.avatar.filename).to eq('donald_duck.jpg')
    expect(user.reload.preferences['daily_digest']).to eq(true)
  end

  scenario 'User update the preferred name' do
    sign_in_user(user, referrer: edit_user_path)
    expect(page).to have_text('Edit').and have_text('profile')

    fill_in 'preferred_name', with: preferred_name
    click_button 'Save Changes'

    expect(page).to have_text('Profile updated successfully!')
    expect(user.reload).to have_attributes(preferred_name: preferred_name)

    visit(dashboard_path)

    expect(page).to have_text(preferred_name)
  end

  scenario 'User sets a new password' do
    sign_in_user(user, referrer: edit_user_path)

    expect(page).to have_text('Set password for your account')
    expect(user.encrypted_password).to be_blank

    # Check a failure path.
    fill_in 'New password', with: 'short'
    fill_in 'Confirm password', with: 'short'

    expect(page).to have_text(
      'New password and confirmation should match and must have atleast 8 characters'
    )

    fill_in 'New password', with: 'long_enough'
    fill_in 'Confirm password', with: 'but_not_the_same'

    expect(page).to have_text(
      'New password and confirmation should match and must have atleast 8 characters'
    )

    # Check basic success.
    fill_in 'New password', with: new_password
    fill_in 'Confirm password', with: new_password

    click_button 'Save Changes'

    expect(page).to have_text('Profile updated successfully!')
    expect(user.reload.valid_password?(new_password)).to eq(true)
  end

  scenario 'user changes the language' do
    sign_in_user(user, referrer: edit_user_path)
    expect(page).to have_text('Localization')

    select 'Russian - русский', from: 'Language'
    click_button 'Save Changes'

    expect(page).to have_text('Profile updated successfully!')

    visit(dashboard_path)

    expect(page).to have_text('Мои Курсы')
  end

  context 'when the user has a password set' do
    before do
      user.password = current_password
      user.password_confirmation = current_password
      user.save!
    end

    scenario 'user changes her password' do
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

  context 'when the user is required to connect a Discord account for a course' do
    let(:course) { student.course }

    around do |example|
      with_secret(sso: { discord: { key: 'DISCORD_KEY' } }) { example.run }
    end

    before do
      course.update!(discord_account_required: true)
      course.school.update(
        configuration: {
          discord: {
            server_id: 'DISCORD_SERVER_ID',
            bot_token: 'DISCORD_BOT_TOKEN'
          }
        }
      )
    end

    scenario 'user is prompted to connect a Discord account; afterwards is shown link to course' do
      sign_in_user(
        user,
        referrer: edit_user_path(course_requiring_discord: course.id)
      )

      expect(page).to have_text('You need to link your Discord account first')

      # Visiting the page after setting the Discord user should show a CTA to return to the course..
      user.update!(discord_user_id: 'DISCORD_USER_ID')

      visit(edit_user_path)

      expect(page).to have_link(
        'take you back to the course',
        href: curriculum_course_path(course)
      )

      # Visiting the page again should not show the prompt.
      visit(edit_user_path)

      expect(page).not_to have_link(
        'take you back to the course',
        href: curriculum_course_path(course)
      )
    end
  end
end
