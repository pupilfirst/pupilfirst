require 'rails_helper'
require 'lita-slack'
require_relative '../../../lib/lita/handlers/backup.rb'

describe Lita::Handlers::Backup do
  let(:robot) { Lita::Robot.new }
  let(:room) { Lita::Room.create_or_update('#general') }
  let(:source) { Lita::Source.new(room: room) }
  let!(:founder) { create :founder_with_password }

  subject { described_class.new(robot) }

  describe '#record_message' do
    let(:message) { Lita::Message.new(robot, 'Hello', source) }

    before :each do
      message.extensions[:slack] = { timestamp: '1234' } # explicitly set the timestamp in the hash
    end

    it 'ignores a private message' do
      allow(message).to receive(:private_message?).and_return(true)
      # no new PublicSlacMessage should be created
      expect { subject.record_message(message: message) }.to_not change { PublicSlackMessage.count }
    end

    it 'records a public message from the room' do
      founder.slack_username = 'username'
      founder.save validate: false # avoid validating the slack_username via Slack API
      allow(message).to receive(:private_message?).and_return(false)
      allow(message).to receive_message_chain(:user, mention_name: 'username')
      # A new PublicSlackMessage should be created
      expect { subject.record_message(message: message) }.to change { PublicSlackMessage.count }.by(1)
      # ensure the created PublicSlackMessage has the right attributes
      last_public_slack_message = PublicSlackMessage.last
      expect(last_public_slack_message.body).to eq(message.body)
      expect(last_public_slack_message.slack_username).to eq(message.user.mention_name)
      expect(last_public_slack_message.founder).to eq(founder)
      expect(last_public_slack_message.channel).to eq('#general')
      expect(last_public_slack_message.timestamp).to eq('1234')
    end
  end

  describe '#record_reaction' do
    let(:item) { { 'type' => 'message', 'channel' => '#general', 'ts' => '123456' } }
    let(:payload) { { name: 'smile', event_ts: '56789', item: item, user: Lita::User.create('username', 'mention_name' => 'username') } }
    let!(:public_slack_message) do
      PublicSlackMessage.create!(body: 'Hello', slack_username: 'username', founder: founder, channel: '#general', timestamp: '123456')
    end

    it 'records a reaction added to an existing message' do
      founder.slack_username = 'username'
      founder.save validate: false
      # A new PublicSlackMessage should be created
      expect { subject.record_reaction(payload) }.to change { PublicSlackMessage.count }.by(1)
      # ensure the created PublicSlackMessage has the right attributes
      last_public_slack_message = PublicSlackMessage.last
      expect(last_public_slack_message.body).to eq(':smile:')
      expect(last_public_slack_message.slack_username).to eq('username')
      expect(last_public_slack_message.founder).to eq(founder)
      expect(last_public_slack_message.channel).to eq('#general')
      expect(last_public_slack_message.timestamp).to eq('56789')
      # ensure reaction is linked to the correct message
      expect(last_public_slack_message.reaction_to).to eq(public_slack_message)
    end

    it 'ignores reaction added to a non-message' do
      payload[:item]['type'] = 'something else'
      expect { subject.record_reaction(payload) }.to_not change { PublicSlackMessage.count }
    end

    it 'ignores reaction if the message reacted to is not found' do
      payload[:item]['ts'] = '1111'
      expect { subject.record_reaction(payload) }.to_not change { PublicSlackMessage.count }
    end
  end

  describe '#remove_reaction' do
    let(:item) { { 'type' => 'message', 'channel' => '#general', 'ts' => '123456' } }
    let(:payload) { { name: 'smile', event_ts: '56789', item: item, user: Lita::User.create('username', 'mention_name' => 'username') } }
    let!(:public_slack_message) do
      PublicSlackMessage.create!(body: 'Hello', slack_username: 'username', founder: founder, channel: '#general', timestamp: '123456')
    end
    let!(:recorded_reaction) do
      PublicSlackMessage.create!(
        body: ':smile:', slack_username: 'username', founder: founder,
        channel: '#general', timestamp: '123457', reaction_to: public_slack_message
      )
    end
    let!(:karma_point_assigned) { create :karma_point, founder: founder, source: recorded_reaction }

    it 'removes associated reaction and karma point if found' do
      expect(KarmaPoint.count).to eq(1)
      expect(PublicSlackMessage.count).to eq(2)
      subject.remove_reaction(payload)
      # KarmaPoint and PublicSlackMessage counts must have changed
      expect(KarmaPoint.count).to eq(0)
      expect(PublicSlackMessage.count).to eq(1)
      # ensure the right reaction and karma point was removed
      expect(PublicSlackMessage.find_by(timestamp: '123457')).to eq(nil)
    end

    it 'ignores reaction removed from a non-message' do
      payload[:item]['type'] = 'something else'
      subject.remove_reaction(payload)
      # KarmaPoint and PublicSlackMessage counts must remain unchanged
      expect(KarmaPoint.count).to eq(1)
      expect(PublicSlackMessage.count).to eq(2)
    end

    it 'ignores reaction removal if the message reacted to is not found' do
      payload[:item]['ts'] = '1111'
      subject.remove_reaction(payload)
      # KarmaPoint and PublicSlackMessage counts must remain unchanged
      expect(KarmaPoint.count).to eq(1)
      expect(PublicSlackMessage.count).to eq(2)
    end

    it 'ignores reaction removal if the reaction was not saved earlier' do
      payload[:name] = 'not smile'
      subject.remove_reaction(payload)
      # KarmaPoint and PublicSlackMessage counts must remain unchanged
      expect(KarmaPoint.count).to eq(1)
      expect(PublicSlackMessage.count).to eq(2)
    end
  end
end
