require 'rails_helper'

require_relative '../../../lib/lita/handlers/leaderboard'

describe Lita::Handlers::Leaderboard do
  describe '#leaderboard' do
    let(:response) { double 'Lita Response Object', match_data: ['1'] }

    context 'when someone asks for the leaderboard' do
      it 'asks to wait and replies on the same channel' do
        expect(subject).to receive(:send_wait_message).with(response)
        expect(response).to receive(:reply).with(subject.leaderboard_response_message)

        subject.leaderboard(response)
      end
    end

    context 'when somebody asks for the leaderboard and it causes an exception' do
      before do
        allow(subject).to receive(:leaderboard_response_message).and_raise('some_exception')
      end

      it 'asks to wait and replies with a sensible message' do
        expect(subject).to receive(:send_wait_message).with(response)
        expect(response).to receive(:reply).with(':confused: Oops! Something seems wrong. Please try again later!')

        subject.leaderboard(response)
      end
    end
  end
end
