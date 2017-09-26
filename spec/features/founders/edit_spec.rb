require 'rails_helper'

include UserSpecHelper

feature 'Founder Edit' do
  let(:startup) { create :startup, :subscription_active }
  let(:founder) { create :founder, college: nil, college_text: 'Anon College of Engineering', born_on: 18.years.ago }
  let(:new_founder_name) { Faker::Name.name }

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
      click_on 'Update details'

      expect(page).to have_text("can't be blank", count: 5)
    end

    scenario 'Founder fills in the required fields and submits' do
      sign_in_user(founder.user, referer: edit_founder_path)

      expect(page).to have_text('Editing').and have_text('profile')
      fill_in 'founders_edit_name', with: new_founder_name
      fill_in 'founders_edit_born_on', with: '1997-01-15'
      fill_in 'founders_edit_phone', with: '9876543210'
      fill_in 'founders_edit_communication_address', with: '37623 Gutmann MountainNorth Adelinetown25858-7040'
      select "My college isn't listed", from: 'founders_edit_college_id'
      click_on 'Update details'

      expect(page).to have_text(new_founder_name)
      expect(page).to have_link('Complete Your Profile')
      expect(page).to have_selector('div.activity-section')
    end
  end

  context 'Exited founder attempts to edit his profile' do
    before do
      founder.update!(exited: true)
    end

    scenario 'founder visits the edit page', js: true do
      sign_in_user(founder.user, referer: edit_founder_path)

      expect(page).to have_text('not an active founder anymore')
    end
  end

  context 'Founder with inactive subscription attempts to edit his profile' do
    let(:startup) { create :startup }

    scenario 'founder visits the edit page' do
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
          first_name: new_founder_name,
          last_name: "(#{startup.product_name})"
        }.to_json,
        token: 'SLACK_ACCESS_TOKEN'
      }.to_query}").to_return(body: { ok: true }.to_json)

      sign_in_user(founder.user, referer: edit_founder_path)

      fill_in 'founders_edit_name', with: new_founder_name

      click_on 'Update details'

      expect(page).to have_content(new_founder_name)
      expect(founder.reload.name).to eq(new_founder_name)
    end
  end
end
