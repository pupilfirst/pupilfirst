require 'spec_helper'

describe V1::SessionsController do
  include V1ApiSpecHelper
  include UserSpecHelper
  include StartupSpecHelper

  describe 'POST on session' do
    before do
      APP_CONFIG[:login_secret] = 'LOGIN_SECRET_KEY'
    end

    after do
      APP_CONFIG[:login_secret] = ENV['LOGIN_SECRET']
    end

    context 'with valid attributes for' do
      it 'user with a password is given' do
        user = create(:user_with_password, password: 'password', password_confirmation: 'password')
        time = Time.now.to_i
        digest = Digest::SHA1.hexdigest("#{time}LOGIN_SECRET_KEY#{user.email}")
        post '/api/users/sessions', {timestamp: time, email: user.email, digest: digest, password: 'password'}, version_header
        expect(response).to be_success
        have_user_object(response, nil, also_check: [:auth_token, :phone, :phone_verified], ignore: [:startup])
      end
    end

    context 'with invalid secret' do
      it 'returns 401 Unauthorized' do
        user = create(:user_with_password, password: 'password', password_confirmation: 'password')
        time = Time.now.to_i
        digest = Digest::SHA1.hexdigest("#{time}wrong_key#{user.email}")
        post '/api/users/sessions', {timestamp: time, email: user.email, digest: digest}, version_header
        expect(response.status).to eq(401)
      end
    end

    context 'with invalid password' do
      it 'returns 422 LoginCredentialsInvalid' do
        user = create(:user_with_password, password: 'password', password_confirmation: 'password')
        time = Time.now.to_i
        digest = Digest::SHA1.hexdigest("#{time}LOGIN_SECRET_KEY#{user.email}")
        post '/api/users/sessions', {timestamp: time, email: user.email, digest: digest, password: 'wrong_password'}, version_header
        expect(response.status).to eq(422)
        expect(parse_json response.body, 'code').to eq 'LoginCredentialsInvalid'
      end
    end

    context 'with only email' do
      it 'should return :bad_request' do
        user = create(:user_with_password, password: 'password', password_confirmation: 'password')
        time = Time.now.to_i
        digest = Digest::SHA1.hexdigest("#{time}LOGIN_SECRET_KEY#{user.email}")
        post '/api/users/sessions', {timestamp: time, email: user.email, digest: digest}, version_header
        expect(response.status).to eq(422)
        expect(parse_json response.body, 'code').to eq 'LoginCredentialsInvalid'
      end
    end
  end

end
