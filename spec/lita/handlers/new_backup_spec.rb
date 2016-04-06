require 'rails_helper'

require_relative '../../../lib/lita/handlers/backup.rb'

describe Lita::Handlers::Backup do
  describe '#record_message' do
    let(:user) { double 'Lita User', mention_name: 'mention_name' }
    let(:room_object) { double 'Lita Room Object', id: 'room_object_id' }
    let(:room) { double 'Lita Room', name: 'channel_name' }
    let(:private_message) { false }
    let(:extensions) { { slack: { timestamp: 'timestamp' } } }
    let(:body) { Faker::Lorem.sentence }
    let(:slack_username_check_response) { { ok: true, members: [{ name: 'mention_name', id: 'ABCD1234' }] }.to_json }

    let(:payload) do
      {
        message: double(
          'Lita Message',
          private_message?: private_message,
          user: user,
          extensions: extensions,
          body: body,
          room_object: room_object
        )
      }
    end

    let(:founder) { create :founder_with_out_password, slack_username: 'mention_name' }

    before do
      allow(Lita::Room).to receive(:find_by_id).with('room_object_id').and_return(room)
      allow(RestClient).to receive(:get).and_return(slack_username_check_response)

      # Memoize founder after stubbing RestClient's get (above).
      founder
    end

    it 'records message' do
      subject.record_message(payload)
      last_public_slack_message = PublicSlackMessage.last

      expect(last_public_slack_message.body).to eq(body)
      expect(last_public_slack_message.slack_username).to eq('mention_name')
      expect(last_public_slack_message.founder).to eq(founder)
      expect(last_public_slack_message.channel).to eq('channel_name')
      expect(last_public_slack_message.timestamp).to eq('timestamp')
    end

    context 'if message is private' do
      let(:private_message) { true }

      it 'does not record message' do
        subject.record_message(payload)
        expect(PublicSlackMessage.count).to eq(0)
      end
    end
  end
end
