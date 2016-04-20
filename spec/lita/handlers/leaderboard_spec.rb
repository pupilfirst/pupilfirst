require 'rails_helper'

require_relative '../../../lib/lita/handlers/leaderboard'

describe Lita::Handlers::Leaderboard do
  describe '#leaderboard' do
    let(:response) { double 'Lita Response Object', match_data: ['1'] }
    let(:slack_username_check_response) { { ok: true, members: [{ name: 'slack_username', id: 'ABCD1234' }] }.to_json }

    context 'when someone asks for the leaderboard from a public channel' do
      before do
        allow(response).to receive_message_chain(:message, :source, :private_message).and_return(false)
        allow(response).to receive_message_chain(:message, :source, :room).and_return('channel_name')
      end

      it 'asks to wait and replies on the same channel' do
        expect(subject).to receive(:send_wait_message).with(response)
        expect(PublicSlackTalk).to receive(:post_message).with(message: instance_of(String), channel: 'channel_name')

        subject.leaderboard(response)
      end
    end

    context 'when a SV.CO founder asks for the leaderboard privately' do
      let(:founder) { create :founder_with_out_password, slack_username: 'slack_username' }

      before do
        allow(response).to receive_message_chain(:message, :source, :private_message).and_return(true)
        allow(response).to receive_message_chain(:message, :source, :user, :metadata).and_return('mention_name' => 'slack_username')
        allow(RestClient).to receive(:get).and_return(slack_username_check_response)
      end

      it 'asks to wait and responds privately via PublicSlackTalk' do
        expect(subject).to receive(:send_wait_message).with(response)
        expect(PublicSlackTalk).to receive(:post_message).with(message: instance_of(String), founder: founder)

        subject.leaderboard(response)
      end
    end

    context 'when a non SV.CO founder asks for the leaderboard privately' do
      before do
        allow(response).to receive_message_chain(:message, :source, :private_message).and_return(true)
        allow(response).to receive_message_chain(:message, :source, :user, :metadata).and_return('mention_name' => 'slack_username')
        allow(response).to receive_message_chain(:message, :source, :room).and_return('channel_name')
      end

      it 'asks to wait and responds privately via slack api' do
        expect(subject).to receive(:send_wait_message).with(response)
        expect(subject).to receive(:reply_using_api_post_message).with(channel: 'channel_name', message: instance_of(String))

        subject.leaderboard(response)
      end
    end

    context 'when somebody asks for the leaderboard and it causes an exception' do
      before do
        allow(response).to receive_message_chain(:message, :source, :private_message).and_raise('some_exception')
      end

      it 'asks to wait and replies with a sensible message' do
        expect(subject).to receive(:send_wait_message).with(response)
        expect(response).to receive(:reply).with(':confused: Oops! Something seems wrong. Please try again later!')

        subject.leaderboard(response)
      end
    end
  end
end
