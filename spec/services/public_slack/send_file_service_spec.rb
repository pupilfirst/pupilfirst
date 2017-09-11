require 'rails_helper'

describe PublicSlack::SendFileService do
  subject { described_class.new(founder, 'content', 'filetype', 'filename') }

  let(:founder) { create :founder }

  describe '.execute' do
    it 'does nothing if founder has no slack_user_id' do
      expect(RestClient).to_not receive(:post)
      subject.upload
    end

    it 'posts to the slack API with the correct payload if founder has a slack_user_id' do
      founder.update!(slack_user_id: 'some_id')
      expect_any_instance_of(described_class).to receive(:channel).and_return('channel_id')

      slack_url = 'https://slack.com/api/files.upload'
      payload = { token: 'BOT_OAUTH_TOKEN',
                  channels: 'channel_id',
                  content: 'content',
                  filetype: 'filetype',
                  filename: 'filename' }

      expect(RestClient).to receive(:post).with(slack_url, payload).and_return('{"ok": "true"}')
      subject.upload
    end
  end
end
