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

  describe '#record_reaction' do
    let(:user) { double 'Lita User', metadata: { 'mention_name' => 'mention_name' } }
    let(:payload) do
      {
        item: { 'type' => 'message', 'ts' => 'timestamp' },
        user: user,
        event_ts: 'event_ts',
        name: 'reaction_type'
      }
    end
    let(:parent_message) { create :public_slack_message, timestamp: 'timestamp', channel: 'channel_name' }
    let(:founder) { create :founder_with_out_password, slack_username: 'mention_name' }
    let(:slack_username_check_response) { { ok: true, members: [{ name: 'mention_name', id: 'ABCD1234' }] }.to_json }

    before do
      allow(RestClient).to receive(:get).and_return(slack_username_check_response)

      # Memoize founder and parent_message
      founder
      parent_message
    end

    it 'records reaction' do
      subject.record_reaction(payload)
      last_public_slack_message = PublicSlackMessage.last

      expect(last_public_slack_message.body).to eq(':reaction_type:')
      expect(last_public_slack_message.slack_username).to eq('mention_name')
      expect(last_public_slack_message.founder).to eq(founder)
      expect(last_public_slack_message.channel).to eq('channel_name')
      expect(last_public_slack_message.timestamp).to eq('event_ts')
    end

    context 'reaction was not to a message' do
      let(:payload) do
        { item: { 'type' => 'not_a_message' } }
      end

      it 'does not record reaction' do
        subject.record_reaction(payload)
        expect(PublicSlackMessage.count).to eq(1)
      end
    end

    context 'parent_message could not be found' do
      let(:payload) do
        {
          item: { 'type' => 'message', 'ts' => 'some_other_timestamp' },
          user: user,
          event_ts: 'event_ts',
          name: 'reaction_type'
        }
      end

      it 'does not record reaction' do
        subject.record_reaction(payload)
        expect(PublicSlackMessage.count).to eq(1)
      end
    end
  end

  describe '#remove_reaction' do
    let(:user) { double 'Lita User', metadata: { 'mention_name' => 'mention_name' } }
    let(:payload) do
      {
        item: { 'type' => 'message', 'ts' => 'timestamp' },
        user: user,
        event_ts: 'event_ts',
        name: 'reaction_type'
      }
    end
    let(:parent_message) { create :public_slack_message, timestamp: 'timestamp', channel: 'channel_name' }
    let(:existing_reaction) { create :public_slack_message, slack_username: 'mention_name', body: ':reaction_type:' }
    let(:karma_point) { create :karma_point }

    before do
      # memoize everything so that .count works fine
      parent_message
      existing_reaction
      karma_point
    end

    it 'removes reaction and associated karma point' do
      # assign existing reaction to the parent message
      existing_reaction.update!(reaction_to: parent_message)

      # assign the karma point to existing_reaction
      karma_point.update!(source: existing_reaction)

      subject.remove_reaction(payload)
      expect(PublicSlackMessage.count).to eq(1)
      expect(KarmaPoint.count).to eq(0)
    end

    context 'reaction to be removed was not to a message' do
      let(:payload) do
        { item: { 'type' => 'not_a_message' } }
      end

      it 'does not modify anything' do
        subject.remove_reaction(payload)
        expect(PublicSlackMessage.count).to eq(2)
        expect(KarmaPoint.count).to eq(1)
      end
    end

    context 'parent_message could not be found' do
      let(:payload) do
        {
          item: { 'type' => 'message', 'ts' => 'some_other_timestamp' }
        }
      end

      it 'does not modify anything' do
        subject.remove_reaction(payload)
        expect(PublicSlackMessage.count).to eq(2)
        expect(KarmaPoint.count).to eq(1)
      end
    end

    context 'reaction to be removed could not be found' do
      let(:existing_reaction) { create :public_slack_message, slack_username: 'mention_name', body: ':some_other_reaction_type:' }

      it 'does not modify anything' do
        subject.remove_reaction(payload)
        expect(PublicSlackMessage.count).to eq(2)
        expect(KarmaPoint.count).to eq(1)
      end
    end
  end
end
