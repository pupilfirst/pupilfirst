require 'rails_helper'

describe Users::AuthenticationService do
  subject { described_class.new(user.school, supplied_token) }

  let(:secret_token) { SecureRandom.urlsafe_base64 }
  let(:login_token_digest) { Digest::SHA2.base64digest(secret_token) }
  let!(:user) do
    create :user,
           login_token_digest: login_token_digest,
           login_token_generated_at: Time.zone.now
  end
  let(:another_school) { create :school }

  describe '#authenticate' do
    context 'when token is invalid' do
      let(:supplied_token) { 'not_this' }

      it 'returns nil' do
        returned_user = subject.authenticate

        expect(returned_user).to eq(nil)
      end
    end

    context 'when token is valid' do
      let(:supplied_token) { secret_token }

      it 'returns the user' do
        returned_user = subject.authenticate

        expect(returned_user).to eq(user)
      end

      it 'clears user token and login email time' do
        expect { subject.authenticate }.to(
          change { user.reload.login_token_digest }
            .from(login_token_digest)
            .to(nil)
        )
        expect(user.login_token_generated_at).to eq(nil)
      end

      context 'when user has no login token generated time' do
        let!(:user) { create :user, login_token_digest: login_token_digest }

        it 'returns nil' do
          expect(subject.authenticate).to eq(nil)
        end
      end

      context 'when a different school is supplied' do
        subject { described_class.new(another_school, supplied_token) }

        it 'returns nil' do
          expect(subject.authenticate).to eq(nil)
        end
      end
    end
  end
end
