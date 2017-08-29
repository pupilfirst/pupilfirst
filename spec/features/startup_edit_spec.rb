require 'rails_helper'

feature 'Startup Edit' do
  include UserSpecHelper

  let!(:startup) { create :startup, :subscription_active }
  let(:founder) { startup.admin }

  let(:new_product_name) { Faker::Lorem.words(rand(3) + 1).join ' ' }
  let(:new_product_description) { Faker::Lorem.words(12).join(' ').truncate(Startup::MAX_PRODUCT_DESCRIPTION_CHARACTERS) }
  let(:new_deck) { Faker::Internet.domain_name }

  context 'Founder visits edit page of his startup' do
    scenario 'Founder updates all required fields' do
      sign_in_user(founder.user, referer: edit_startup_path)

      fill_in 'startup_product_name', with: new_product_name
      fill_in 'startup_product_description', with: new_product_description
      fill_in 'startup_presentation_link', with: new_deck

      click_on 'Update startup profile'

      # Wait for page to load before checking database.
      expect(page).to have_content(new_product_name)

      startup.reload

      expect(startup.product_name).to eq(new_product_name)
      expect(startup.product_description).to eq(new_product_description)
      expect(startup.presentation_link).to eq(new_deck)
    end

    scenario 'Founder clears all required fields' do
      sign_in_user(founder.user, referer: edit_startup_path)

      fill_in 'startup_product_name', with: ''
      click_on 'Update startup profile'

      expect(page).to have_text('Please review the problems below')
      expect(page).to have_selector('div.form-group.startup_product_name.has-error')
    end

    scenario 'Founder looks to delete his approved startup as startup_admin' do
      sign_in_user(founder.user, referer: edit_startup_path)

      expect(page).to have_text('To delete your startup timeline, contact your SV.CO representative.')
    end
  end

  context 'when founder is connected to Slack' do
    before do
      founder.update(slack_access_token: 'SLACK_ACCESS_TOKEN', slack_user_id: 'SLACK_USER_ID')
    end

    scenario 'Founder udpates product name' do
      # Stub the access token lookup.
      stub_request(:get, 'https://slack.com/api/auth.test?token=SLACK_ACCESS_TOKEN')
        .to_return(body: { ok: true }.to_json)

      sign_in_user(founder.user, referer: edit_startup_path)

      # Stub the calls to update profile name on Slack for all founders.
      startup.founders.each do |startup_founder|
        stub_request(:get, "https://slack.com/api/users.profile.set?#{{
          profile: {
            first_name: startup_founder.name,
            last_name: "(#{new_product_name})"
          }.to_json,
          token: 'SLACK_ACCESS_TOKEN'
        }.to_query}").to_return(body: { ok: true }.to_json)
      end

      fill_in 'startup_product_name', with: new_product_name
      click_on 'Update startup profile'

      expect(page).to have_content(new_product_name)
      expect(startup.reload.product_name).to eq(new_product_name)
    end
  end
end
