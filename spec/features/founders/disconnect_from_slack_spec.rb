require 'rails_helper'

feature 'Disconnect from Slack' do
  include UserSpecHelper

  let(:startup) { create :startup, :subscription_active }
  let(:founder) { create :founder, :connected_to_slack }

  before do
    startup.founders << founder
  end

  scenario 'Founder disconnects Slack account' do
    pending 'Slack connect feature is hidden'

    # Stub the call to check token.
    stub_request(:get, 'https://slack.com/api/auth.test?token=SLACK_ACCESS_TOKEN')
      .to_return(body: { ok: true }.to_json)

    # Stub the call to revoke the token.
    stub_request(:get, 'https://slack.com/api/auth.revoke?token=SLACK_ACCESS_TOKEN')
      .to_return(body: { ok: true }.to_json)

    sign_in_user founder.user, referer: edit_founder_path

    expect(page).to have_content('Your username on Slack is SLACK_USERNAME.')

    click_link('Disconnect')

    expect(page).to have_content('Keep your profile name on Slack up-to-date, in the required format')

    # The access token should be removed.
    expect(founder.reload.slack_access_token).to eq(nil)

    # Preserve the other details.
    expect(founder.slack_username).to eq('SLACK_USERNAME')
    expect(founder.slack_user_id).to eq('SLACK_USER_ID')
  end
end
