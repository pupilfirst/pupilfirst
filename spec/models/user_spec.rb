require 'rails_helper'
require 'webmock/rspec'

describe User do
  before :all do
    APP_CONFIG[:vocalist_api_token] = 'xxxxxx'
  end

  before :each do
    stub_request(:get, "https://slack.com/api/users.list?token=xxxxxx")
      .to_return(body: '{"ok":true,"members":[{"id":"UABCDEFGH","name":"slackuser"}]}')
  end

  context 'non_founders scopes' do
    it 'returns users who are not related to any startup' do
      user = create(:user_with_out_password, startup: nil)
      expect(User.non_founders.map(&:id)).to include(user.id)
    end
  end

  describe '#remove_from_startup!' do
    it 'disassociates a user from startup completely' do
      startup = create :startup
      founder = startup.founders.first
      founder.remove_from_startup!
      founder.reload
      expect(founder.startup).to eq nil
      expect(founder.is_founder).to eq nil
      expect(founder.startup_admin).to eq nil
    end
  end

  context 'user updates slack_username to a random name not on public slack' do
    it 'validates absence of username in SV.CO public slack and raises error' do
      user = create :user_with_password
      user.update(slack_username: 'abc')
      expect(a_request(:get, "https://slack.com/api/users.list?token=xxxxxx")).to have_been_made.once
      expect(user.errors[:slack_username]).to include('a user with this mention name does not exist on SV.CO Public Slack')
    end
  end

  context 'user updates slack_username to a valid name on public slack' do
    it 'validates presence of username in SV.CO public slack and updates succesfully' do
      user = create :user_with_password
      user.update(slack_username: 'slackuser')
      expect(a_request(:get, "https://slack.com/api/users.list?token=xxxxxx")).to have_been_made.once
      expect(user.errors[:slack_username]).to be_empty
      expect(user.slack_user_id).to_not be_nil
    end
  end

  context 'user empties slack_username' do
    it 'clears slack_user_id and sends no query to slack' do
      user = create :user_with_password
      user.update(slack_username: '')
      expect(a_request(:get, "https://slack.com/api/users.list?token=xxxxxx")).not_to have_been_made
      expect(user.slack_username).to be_nil
      expect(user.slack_user_id).to be_nil
    end
  end
end
