require 'rails_helper'

describe UserAuthenticationService do
  subject { described_class }

  include Capybara::Email::DSL

  let!(:user) { create :user, email: 'valid_email@example.com' }

  context 'invoked to mail login token' do
    scenario 'user with given email does not exist' do
      response = subject.mail_login_token('random@example.com', 'some_referer')

      # it returns user not found error
      expect(response[:success]).to be_falsey
      expect(response[:message]).to eq('Could not find user with given email.')
    end

    scenario 'user with given email exists' do
      response = subject.mail_login_token('valid_email@example.com', 'www.example.com')

      expect(response[:success]).to be_truthy
      expect(response[:message]).to eq('Login token successfully emailed.')

      # it successfully emails login link with token and referer
      open_email('valid_email@example.com')
      expect(current_email.subject).to eq('Log in to SV.CO')
      expect(current_email.body).to include('http://localhost:3000/user_login_with_token?')
      expect(current_email.body).to include('referer=www.example.com')
      expect(current_email.body).to include("token=#{user.login_token}")
    end
  end

  context 'invoked to authenticate a token' do
    scenario 'user with given email does not exist' do
      response = subject.authenticate_token('random@example.com', 'some_token')

      # it returns authentication failure
      expect(response[:success]).to be_falsey
      expect(response[:message]).to eq('User authentication failed.')
    end

    scenario 'user with given email exists but token is invalid' do
      response = subject.authenticate_token(user.email, 'some_token')

      # it returns authentication failure
      expect(response[:success]).to be_falsey
      expect(response[:message]).to eq('User authentication failed.')
    end

    scenario 'user with given email exists and token is valid' do
      response = subject.authenticate_token(user.email, user.login_token)

      # it returns authentication success
      expect(response[:success]).to be_truthy
      expect(response[:message]).to eq('User authenticated successfully.')
    end
  end
end
