require 'rails_helper'

feature 'User Profile Edit' do
  include UserSpecHelper

  let(:startup) { create :startup }
  let(:founder) { create :founder }
  let(:founder_name) { Faker::Name.name }
  let(:phone) { rand(9_876_543_210..9_876_553_209) }
  let(:communication_address) { Faker::Address.full_address }
  let(:username) { Faker::Internet.user_name(founder_name, %w[-]) }
  let(:about) { Faker::Lorem.paragraphs.join(" ") }

  def upload_path(file)
    File.absolute_path(Rails.root.join('spec', 'support', 'uploads', file))
  end

  before do
    startup.founders << founder
  end

  context 'Active founder visits edit page of his profile' do
    scenario 'Founder tries to submit a blank form' do
      sign_in_user(founder.user, referer: edit_user_profile_path)

      expect(page).to have_text('Edit your profile')

      fill_in 'user_profiles_edit_name', with: ''
      fill_in 'user_profiles_edit_phone', with: ''
      fill_in 'user_profiles_edit_communication_address', with: ''
      click_button 'Save Changes'

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Phone can't be blank")
      expect(page).to have_content("Communication address can't be blank")
    end

    scenario 'Founder fills in all fields and submits' do
      sign_in_user(founder.user, referer: edit_user_profile_path)
      expect(page).to have_text('Edit').and have_text('profile')

      fill_in 'user_profiles_edit_name', with: founder_name
      fill_in 'user_profiles_edit_phone', with: phone
      attach_file 'user_profiles_edit_avatar', upload_path('faculty/donald_duck.jpg')
      fill_in 'user_profiles_edit_about', with: about
      fill_in 'user_profiles_edit_skype_id', with: username
      fill_in 'user_profiles_edit_communication_address', with: communication_address
      fill_in 'user_profiles_edit_twitter_url', with: "https://twitter.com/#{username}"
      fill_in 'user_profiles_edit_linkedin_url', with: "https://linkedin.com/#{username}"
      fill_in 'user_profiles_edit_personal_website_url', with: "https://#{username}.com"
      fill_in 'user_profiles_edit_blog_url', with: "https://blog.#{username}.com"
      fill_in 'user_profiles_edit_angel_co_url', with: "https://angel.co/#{username}"
      fill_in 'user_profiles_edit_github_url', with: "https://github.com/#{username}"
      fill_in 'user_profiles_edit_behance_url', with: "https://behance.net/#{username}"

      click_button 'Save Changes'

      expect(page).to have_text(founder_name)
      expect(page).to have_selector('div.profile-data')

      # Confirm that founder has, indeed, been updated.
      expect(founder.reload).to have_attributes(
        name: founder_name,
        phone: phone.to_s,
        about: about,
        skype_id: username,
        communication_address: communication_address,
        twitter_url: "https://twitter.com/#{username}",
        linkedin_url: "https://linkedin.com/#{username}",
        personal_website_url: "https://#{username}.com",
        blog_url: "https://blog.#{username}.com",
        angel_co_url: "https://angel.co/#{username}",
        github_url: "https://github.com/#{username}",
        behance_url: "https://behance.net/#{username}"
      )

      expect(founder.avatar.filename).to eq('donald_duck.jpg')
    end
  end
end
