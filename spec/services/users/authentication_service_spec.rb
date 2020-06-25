require 'rails_helper'

describe Users::AuthenticationService do
  subject { described_class.new(user.school, supplied_token) }

  let(:secret_token) { SecureRandom.hex }
  let!(:user) { create :user, login_token: secret_token }
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

      it 'clears user token' do
        expect { subject.authenticate }.to(change { user.reload.login_token }.from(secret_token).to(nil))
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
