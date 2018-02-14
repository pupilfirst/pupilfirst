require 'rails_helper'

include UserSpecHelper

feature 'Founder Edit' do
  let(:startup) { create :startup, :subscription_active }
  let(:founder) { create :founder, college: nil, college_text: 'Anon College of Engineering', born_on: 18.years.ago }
  let(:founder_name) { Faker::Name.name }
  let(:phone) { 9_876_543_210 + rand(10_000) }
  let(:communication_address) { Faker::Address.full_address }
  let(:username) { Faker::Internet.user_name(founder_name, %w[-]) }
  let(:backlogs) { rand(10) }
  let(:semester) { %w[I II III IV V VI VII VIII].sample }
  let(:course) { "#{%w[B-tech PG-diploma M-tech Bachelors].sample} in #{Faker::Lorem.word.capitalize}" }
  let(:roll_number) { "UNI00#{10_000 + rand(9_999)}" }
  let(:roles) { %w[Product Design Engineering].sample(2) }
  let(:one_liner) { Faker::Lorem.sentence }

  def upload_path(file)
    File.absolute_path(Rails.root.join('spec', 'support', 'uploads', file))
  end

  before do
    startup.founders << founder
  end

  context 'Active founder visits edit page of his profile' do
    scenario 'Founder tries to submit a blank form' do
      sign_in_user(founder.user, referer: edit_founder_path)

      expect(page).to have_text('Editing').and have_text('profile')

      fill_in 'founders_edit_name', with: ''
      fill_in 'founders_edit_born_on', with: ''
      fill_in 'founders_edit_phone', with: ''
      fill_in 'founders_edit_communication_address', with: ''
      click_button 'Save Changes'

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Born on can't be blank")
      expect(page).to have_content("Phone can't be blank")
      expect(page).to have_content("Communication address can't be blank")
    end

    scenario 'Founder fills in all fields and submits' do
      sign_in_user(founder.user, referer: edit_founder_path)
      expect(page).to have_text('Editing').and have_text('profile')

      fill_in 'founders_edit_name', with: founder_name
      fill_in 'founders_edit_born_on', with: '1997-01-15'
      fill_in 'founders_edit_phone', with: phone
      attach_file 'founders_edit_avatar', upload_path('faculty/donald_duck.jpg')
      fill_in 'founders_edit_about', with: one_liner

      # Choose two roles.
      roles.each do |role|
        select role, from: 'founders_edit_roles'
      end

      fill_in 'founders_edit_skype_id', with: username
      fill_in 'founders_edit_communication_address', with: communication_address
      attach_file 'founders_edit_identification_proof', upload_path('resources/pdf-thumbnail.png')
      select "My college isn't listed", from: 'founders_edit_college_id'
      fill_in 'founders_edit_roll_number', with: roll_number
      attach_file 'founders_edit_college_identification', upload_path('users/college_id.jpg')
      fill_in 'founders_edit_course', with: course
      select semester, from: 'founders_edit_semester'
      select (Time.zone.now.year + rand(4)).to_s, from: 'founders_edit_year_of_graduation'
      fill_in 'founders_edit_backlog', with: backlogs
      fill_in 'founders_edit_twitter_url', with: "https://twitter.com/#{username}"
      fill_in 'founders_edit_linkedin_url', with: "https://linkedin.com/#{username}"
      fill_in 'founders_edit_personal_website_url', with: "https://#{username}.com"
      fill_in 'founders_edit_blog_url', with: "https://blog.#{username}.com"
      fill_in 'founders_edit_angel_co_url', with: "https://angel.co/#{username}"
      fill_in 'founders_edit_github_url', with: "https://github.com/#{username}"
      fill_in 'founders_edit_behance_url', with: "https://behance.net/#{username}"

      click_button 'Save Changes'

      expect(page).to have_text(founder_name)
      expect(page).to have_link('Complete Your Profile')
      expect(page).to have_selector('div.activity-section')

      # Confirm that founder has, indeed, been updated.
      expect(founder.reload).to have_attributes(
        name: founder_name,
        born_on: Date.parse('1997-01-15'),
        phone: phone.to_s,
        about: one_liner,
        skype_id: username,
        communication_address: communication_address,
        roll_number: roll_number,
        course: course,
        semester: semester,
        backlog: backlogs,
        twitter_url: "https://twitter.com/#{username}",
        linkedin_url: "https://linkedin.com/#{username}",
        personal_website_url: "https://#{username}.com",
        blog_url: "https://blog.#{username}.com",
        angel_co_url: "https://angel.co/#{username}",
        github_url: "https://github.com/#{username}",
        behance_url: "https://behance.net/#{username}"
      )

      expect(founder.avatar.file.filename).to eq('donald_duck.jpg')
      expect(founder.roles).to match_array(roles.map(&:downcase))
      expect(founder.identification_proof.file.filename).to eq('pdf-thumbnail.png')
      expect(founder.college_identification.file.filename).to eq('college_id.jpg')
    end

    scenario 'Founder tries to submit invalid values' do
      sign_in_user(founder.user, referer: edit_founder_path)
      expect(page).to have_text('Editing').and have_text('profile')

      fill_in 'founders_edit_backlog', with: '-2'
      click_button 'Save Changes'

      expect(page).to have_content('Backlog must be greater than or equal to 0')
    end
  end

  context 'Exited founder attempts to edit his profile' do
    before do
      founder.update!(exited: true)
    end

    scenario 'founder visits the edit page', js: true do
      sign_in_user(founder.user, referer: edit_founder_path)

      expect(page).to have_text('not an active student anymore')
    end
  end

  context 'Founder with inactive subscription attempts to edit his profile' do
    let(:startup) { create :startup }

    scenario 'founder visits the edit page' do
      pending 'Fee payment disabled'

      sign_in_user(founder.user, referer: edit_founder_path)

      # Create a pending payment.
      create :payment, startup: startup

      sign_in_user(founder.user, referer: edit_founder_path)
      expect(page).to have_content('Please pay the membership fee to continue.')
    end
  end

  context 'founder has connected slack account' do
    let(:founder) do
      create(:founder, :connected_to_slack,
        born_on: 18.years.ago,
        communication_address: 'Foo')
    end

    scenario 'founder updates his name' do
      # Stub the access token lookup.
      stub_request(:get, 'https://slack.com/api/auth.test?token=SLACK_ACCESS_TOKEN')
        .to_return(body: { ok: true }.to_json)

      # Stub the calls to update profile name on Slack for all founders.
      stub_request(:get, "https://slack.com/api/users.profile.set?#{{
        profile: {
          first_name: founder_name,
          last_name: "(#{startup.product_name})"
        }.to_json,
        token: 'SLACK_ACCESS_TOKEN'
      }.to_query}").to_return(body: { ok: true }.to_json)

      sign_in_user(founder.user, referer: edit_founder_path)

      fill_in 'founders_edit_name', with: founder_name

      click_button 'Save Changes'

      expect(page).to have_content(founder_name)
      expect(founder.reload.name).to eq(founder_name)
    end
  end
end
