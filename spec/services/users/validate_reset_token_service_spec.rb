require 'rails_helper'

describe Users::ValidateResetTokenService do
  let!(:token) { SecureRandom.uuid }
  subject { described_class.new(token) }

  describe '#authenticate' do
    it 'returns nil if no user has the token' do
      create :user
      serv = described_class.new(token)
      expect(serv.authenticate).to eq(nil)
    end

    context 'with time limit' do
      let(:time_limit_minutes) { 3 }

      before do
        allow(subject).to receive(:time_limitation?) { true }
        allow(subject).to receive(:time_limit_minutes) { time_limit_minutes.minutes }
      end

      it 'returns user based on #reset_password_token' do
        sent_at = Time.zone.now - (time_limit_minutes - 1).minutes
        user = create :user, reset_password_token: token, reset_password_sent_at: sent_at
        expect(subject.authenticate).to eq(user)
      end

      it 'returns nil due to time limit' do
        sent_at = Time.zone.now - (time_limit_minutes + 1).minutes
        create :user, reset_password_sent_at: sent_at
        expect(subject.authenticate).to eq(nil)
      end
    end

    context 'without time limit' do
      before do
        allow(subject).to receive(:time_limitation?) { false }
      end

      it 'returns user based on #reset_password_token' do
        user = create :user, reset_password_token: token
        expect(subject.authenticate).to eq(user)
      end
    end
  end
end
