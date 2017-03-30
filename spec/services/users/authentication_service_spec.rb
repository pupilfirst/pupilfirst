require 'rails_helper'

describe Users::AuthenticationService do
  subject { described_class }

  let!(:user) { create :user, email: 'valid_email@example.com' }

  describe '.mail_login_token' do
    context 'when a user with supplied email does not exist' do
      it 'responds with error message' do
        response = subject.mail_login_token('random@example.com', 'some_referer', true)

        # it returns user not found error
        expect(response[:success]).to be_falsey
        expect(response[:message]).to eq('Could not find user with given email.')
      end
    end

    context 'when user with supplied email exists' do
      it 'generates new login token' do
        expect do
          subject.mail_login_token('valid_email@example.com', 'www.example.com', true)
        end.to(change { user.reload.login_token })
      end

      it 'emails login link to user' do
        subject.mail_login_token('valid_email@example.com', 'www.example.com', true)

        user.reload

        open_email('valid_email@example.com')
        expect(current_email.subject).to eq('Log in to SV.CO')
        expect(current_email.body).to include('http://localhost:3000/users/token?')
        expect(current_email.body).to include('referer=www.example.com')
        expect(current_email.body).to include("token=#{user.login_token}")
      end

      it 'responds with success message' do
        response = subject.mail_login_token('valid_email@example.com', 'www.example.com', true)

        expect(response[:success]).to be_truthy
        expect(response[:message]).to eq('Login token successfully emailed.')
      end
    end
  end

  describe '.authenticate_token' do
    context 'when token is invalid' do
      it 'responds with error message' do
        response = subject.authenticate_token('some_token')

        # it returns authentication failure
        expect(response[:success]).to be_falsey
        expect(response[:message]).to eq('User authentication failed.')
      end
    end

    context 'when token is valid' do
      let!(:response) { subject.authenticate_token(user.login_token) }

      it 'responds with success message' do
        # it returns authentication success
        expect(response[:success]).to be_truthy
        expect(response[:message]).to eq('User authenticated successfully.')
      end

      it 'clears user token' do
        user.reload
        expect(user.login_token).to eq(nil)
      end
    end
  end
end
