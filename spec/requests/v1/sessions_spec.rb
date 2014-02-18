require 'spec_helper'

describe V1::SessionsController do
	include V1ApiSpecHelper

  describe "POST on session" do
  	context "with valid attributes for" do
	    it "user with a password is given" do
	    	user = create(:user_with_password, password: 'password', password_confirmation: 'password')
	      time = Time.now.to_i
	      digest = Digest::SHA1.hexdigest("#{time}#{Svapp::Application.config.secret_key_base}#{user.email}")
	      post '/api/users/sessions', {timestamp: time, email: user.email, digest: digest, password: 'password'}, version_header
	      expect(response).to be_success
				expect(response.body).to have_json_path("id")
	      expect(response.body).to have_json_type(Integer).at_path("id")
	      expect(response.body).to have_json_path("auth_token")
	      response_json = %({"id":#{user.id},"auth_token":"#{user.auth_token}"})
	      expect(response.body).to be_json_eql(response_json)
	    end

	    it "user with secret & social_id is given" do
	    	user = create(:user_with_facebook)
	      time = Time.now.to_i
	      digest = Digest::SHA1.hexdigest("#{time}#{Svapp::Application.config.secret_key_base}#{user.social_ids.first.social_id}#{user.email}")
	      post '/api/users/sessions', {timestamp: time, email: user.email, digest: digest, social_id: user.social_ids.first.social_id, provider: 'facebook'}, version_header
	      expect(response).to be_success
				expect(response.body).to have_json_path("id")
	      expect(response.body).to have_json_type(Integer).at_path("id")
	      expect(response.body).to have_json_path("auth_token")
	      response_json = %({"id":#{user.id},"auth_token":"#{user.auth_token}"})
	      expect(response.body).to be_json_eql(response_json)
	    end
	  end

	  context "with invalid secret" do
	  	it "should returns :unauthorized" do
	    	user = create(:user_with_password, password: 'password', password_confirmation: 'password')
	      time = Time.now.to_i
	      digest = Digest::SHA1.hexdigest("#{time}wrongkey#{user.email}")
	      post '/api/users/sessions', {timestamp: time, email: user.email, digest: digest}, version_header
	      expect(response.status).to eq(401)
	  	end
	  end

	  context 'with invalid password' do
	  	it "should returns :bad_request" do
	    	user = create(:user_with_password, password: 'password', password_confirmation: 'password')
	      time = Time.now.to_i
	      digest = Digest::SHA1.hexdigest("#{time}#{Svapp::Application.config.secret_key_base}#{user.email}")
	      post '/api/users/sessions', {timestamp: time, email: user.email, digest: digest, password: 'wrongpassword'}, version_header
	      expect(response.status).to eq(400)
	  	end
	  end

	  context 'with invalid social_id' do
	  	it "should returns :bad_request" do
	    	user = create(:user_with_facebook)
	      time = Time.now.to_i
	      digest = Digest::SHA1.hexdigest("#{time}#{Svapp::Application.config.secret_key_base}#{"bad_social_id"}#{user.email}")
	      post '/api/users/sessions', {timestamp: time, email: user.email, digest: digest, social_id: "bad_social_id"}, version_header
	      expect(response.status).to eq(400)
	  	end
	  end

	  context "with only email" do
	  	it "should return :bad_request" do
	    	user = create(:user_with_password, password: 'password', password_confirmation: 'password')
	      time = Time.now.to_i
	      digest = Digest::SHA1.hexdigest("#{time}#{Svapp::Application.config.secret_key_base}#{user.email}")
	      post '/api/users/sessions', {timestamp: time, email: user.email, digest: digest}, version_header
	      expect(response.status).to eq(400)
	  	end
	  end
  end

end
