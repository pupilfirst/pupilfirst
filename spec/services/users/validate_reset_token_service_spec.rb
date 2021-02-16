require 'rails_helper'

describe Users::ValidateResetTokenService do
  include WithEnvHelper

  let(:token) { SecureRandom.uuid }
  let(:time_limit) { nil }
  let(:sent_at) { Time.zone.now }
  let!(:user) { create :user, reset_password_token: token, reset_password_sent_at: sent_at }

  subject { described_class.new(token) }

  around do |example|
    with_env(RESET_PASSWORD_TOKEN_TIME_LIMIT: time_limit.to_s) do
      example.run
    end
  end

  describe '#authenticate' do
    context 'when the token does not match any user' do
      let!(:user) { create :user }

      it 'returns nil' do
        expect(subject.authenticate).to eq(nil)
      end
    end

    context 'when a time limit exists' do
      let(:time_limit) { 3 }

      context 'within time limit' do
        let(:sent_at) { Time.zone.now - 1.minute }

        it 'returns user based on #reset_password_token' do
          expect(subject.authenticate).to eq(user)
        end
      end

      context 'beyond the time limit' do
        let(:sent_at) { Time.zone.now - 4.minutes }

        it 'returns nil due to time limit' do
          expect(subject.authenticate).to eq(nil)
        end
      end
    end

    context 'without a configured time limit' do
      context 'within default time limit' do
        let(:sent_at) { Time.zone.now - 28.minutes }

        it 'returns user based on #reset_password_token' do
          expect(subject.authenticate).to eq(user)
        end
      end

      context 'beyond the default time limit' do
        let(:sent_at) { Time.zone.now - 31.minutes }

        it 'returns nil due to time limit' do
          expect(subject.authenticate).to eq(nil)
        end
      end
    end
  end
end
