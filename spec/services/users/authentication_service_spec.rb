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
        end.to change { user.reload.login_token }
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

  describe '.user_from_oauth' do
    context "when supplied with an existing user's email" do
      it 'returns user' do
        returned_user = subject.user_from_oauth(info: { email: user.email })
        expect(returned_user).to eq(user)
      end
    end

    context 'when supplied with a new email address' do
      it 'creates new user' do
        expect do
          subject.user_from_oauth(info: { email: 'new_user@example.com' })
        end.to change(User, :count).by(1)
      end

      it 'returns new user' do
        returned_user = subject.user_from_oauth(info: { email: 'new_user@example.com' })

        expect(returned_user).to be_a(User)
        expect(returned_user).to be_persisted
        expect(returned_user.email).to eq('new_user@example.com')
      end
    end
  end
end
