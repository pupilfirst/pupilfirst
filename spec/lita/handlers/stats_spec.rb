require 'rails_helper'

require_relative '../../../lib/lita/handlers/stats'

describe Lita::Handlers::Stats do
  let(:response) { double 'Lita Response Object', match_data: %w(something 1) }
  context 'when a batch with the specified batch_number exists' do
    let!(:batch) { create :batch, batch_number: 1 }

    describe '#state_of_batch' do
      it 'sends the state of batch stats' do
        expect(subject).to receive(:reply_with_state_of_batch)
        subject.state_of_batch response
      end
    end

    describe '#expired_team_targets' do
      it 'sends list of expired team targets' do
        expect(subject).to receive(:reply_with_expired_team_targets)
        subject.expired_team_targets response
      end
    end

    describe '#expired_founder_targets' do
      it 'sends list of expired founder targets' do
        expect(subject).to receive(:reply_with_expired_founder_targets)
        subject.expired_founder_targets response
      end
    end
  end

  context 'when a batch with the specified batch_number does not exist' do
    let!(:batch) { create :batch, batch_number: 2 }

    describe '#state_of_batch' do
      it 'sends a batch missing error message' do
        expect(subject).to receive(:send_batch_missing_message)
        subject.state_of_batch response
      end
    end

    describe '#expired_team_targets' do
      it 'sends a batch missing error message' do
        expect(subject).to receive(:send_batch_missing_message)
        subject.expired_team_targets response
      end
    end

    describe '#expired_founder_targets' do
      it 'sends a batch missing error message' do
        expect(subject).to receive(:send_batch_missing_message)
        subject.expired_founder_targets response
      end
    end
  end
end
