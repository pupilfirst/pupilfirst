require 'rails_helper'

feature 'Connect to Slack' do
  include UserSpecHelper

  let(:startup) { create :startup, :subscription_active }
  let(:founder) { startup.admin }

  before do
    Rails.application.secrets.slack = {
      name: 'sv',
      app: {
        client_id: 'CLIENT_ID',
        client_secret: 'CLIENT_SECRET',
        bot_oauth_token: 'BOT_OAUTH_TOKEN'
      },
      channels: {
        public: %w[public-channel],
        private: %w[private-channel]
      }
    }
  end

  scenario 'Founder connects profile to Slack' do
    sign_in_user founder.user, referer: edit_founder_path

    expect(page).to have_content('Keep your profile name on Slack up-to-date, in the required format')

    click_link 'Connect'

    expect(page).to have_content('redirected to: https://sv.slack.com/oauth?client_id=CLIENT_ID&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Ffounder%2Fslack%2Fcallback&scope=users.profile%3Awrite')

    # Stub the request to retrieve access token from API.
    stub_request(:get, 'https://slack.com/api/oauth.access?client_id=CLIENT_ID&client_secret=CLIENT_SECRET&code=OAUTH_CODE&redirect_uri=http://localhost:3000/founder/slack/callback')
      .to_return(body: { ok: true, access_token: 'ACCESS_TOKEN', user_id: 'USER_ID' }.to_json)

    # Stub the request to retrieve username from Slack.
    stub_request(:get, 'https://slack.com/api/users.info?user=USER_ID')
      .to_return(body: { ok: true, user: { name: 'USER_NAME' } }.to_json)

    # Stub the request to check whether token is valid.
    stub_request(:get, 'https://slack.com/api/auth.test?token=ACCESS_TOKEN').to_return(body: { ok: true }.to_json)

    # Stub the request to update user profile.
    stub_request(:get, "https://slack.com/api/users.profile.set?#{{
      profile: {
        first_name: founder.name,
        last_name: "(#{startup.product_name})"
      }.to_json,
      token: 'ACCESS_TOKEN'
    }.to_query}").to_return(body: { ok: true }.to_json)

    # Stub the request to list public channels.
    stub_request(:get, 'https://slack.com/api/channels.list?exclude_archived=true&exclude_members=true&token=BOT_OAUTH_TOKEN')
      .to_return(body: { ok: true, channels: [{ name: 'public-channel', id: 'PUBLIC_CHANNEL' }] }.to_json)

    # Stub the request to list private channels.
    stub_request(:get, 'https://slack.com/api/groups.list?exclude_archived=true&exclude_members=true&token=BOT_OAUTH_TOKEN')
      .to_return(body: { ok: true, groups: [{ name: 'private-channel', id: 'PRIVATE_CHANNEL' }] }.to_json)

    # Stub the request to invite founder to public channels.
    stub_request(:get, 'https://slack.com/api/channels.invite?channel=PUBLIC_CHANNEL&user=USER_ID&token=BOT_OAUTH_TOKEN')
      .to_return(body: { ok: true }.to_json)

    # Stub the request to invite founder to public channels.
    stub_request(:get, 'https://slack.com/api/groups.invite?channel=PRIVATE_CHANNEL&user=USER_ID&token=BOT_OAUTH_TOKEN')
      .to_return(body: { ok: true }.to_json)

    visit(founder_slack_callback_path(code: 'OAUTH_CODE'))

    expect(page).to have_content('Your username on Slack is USER_NAME.')
    expect(founder.reload.slack_access_token).to eq('ACCESS_TOKEN')
    expect(founder.slack_user_id).to eq('USER_ID')
    expect(founder.slack_username).to eq('USER_NAME')
  end
end
