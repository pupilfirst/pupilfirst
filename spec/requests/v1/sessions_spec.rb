require 'spec_helper'

describe V1::SessionsController do
	include V1ApiSpecHelper
	include UserSpecHelper
	include StartupSpecHelper

  describe "POST on session" do
  	context "with valid attributes for" do
	    it "user with a password is given" do
	    	user = create(:user_with_password, password: 'password', password_confirmation: 'password')
	      time = Time.now.to_i
	      digest = Digest::SHA1.hexdigest("#{time}#{Svapp::Application.config.secret_key_base}#{user.email}")
	      post '/api/users/sessions', {timestamp: time, email: user.email, digest: digest, password: 'password'}, version_header
	      expect(response).to be_success
	      have_user_object(response, 'user', also_check: [:auth_token], ignore: [:startup])
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
	      expect(response.status).to eq(200)
	      expect(parse_json(response.body, 'success')).to eql(false)
		    expect(response.body).to have_json_path("success")
		    expect(response.body).to have_json_path("user")
	      expect(parse_json(response.body, 'user')).to eql(nil)
	  	end
	  end

	  context "with only email" do
	  	it "should return :bad_request" do
	    	user = create(:user_with_password, password: 'password', password_confirmation: 'password')
	      time = Time.now.to_i
	      digest = Digest::SHA1.hexdigest("#{time}#{Svapp::Application.config.secret_key_base}#{user.email}")
	      post '/api/users/sessions', {timestamp: time, email: user.email, digest: digest}, version_header
	      expect(response.status).to eq(200)
	      expect(parse_json(response.body, 'success')).to eql(false)
		    expect(response.body).to have_json_path("success")
		    expect(response.body).to have_json_path("user")
	      expect(parse_json(response.body, 'user')).to eql(nil)
	  	end
	  end
  end

end
