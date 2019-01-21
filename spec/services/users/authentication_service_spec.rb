require 'rails_helper'

describe Users::AuthenticationService do
  subject { described_class.new(supplied_token) }

  let(:secret_token) { SecureRandom.hex }
  let!(:user) { create :user, login_token: secret_token }

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
    end
  end
end
