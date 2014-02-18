require 'spec_helper'

describe V1::UsersController do
	include V1ApiSpecHelper

  describe "GET on user" do
  	context "fetches details of user when id is provided" do
	    it "returns http success with details" do
	      pending "check for details once design arives"
	    	user = create(:user_with_out_password)
	      get "/api/users/#{user.id}", {}, version_header
	      expect(response).to be_success
	    end
	  end
  end

  describe "POST on user" do
  	context 'with valid attributes and no password' do
  		it "should create user" do
  			attributes = attributes_for(:user_with_out_password)
				post '/api/users', {user: attributes}, version_header
	      expect(response.status).to eq(201)
	      response_user_id = JSON.parse(response.body)['id']
				expect(User.find(response_user_id).email).to eq(attributes[:email])
  		end
	  end

  	context 'with valid attributes and valid password' do
  		it "should create user" do
  			dob = Time.parse('2000-5-5').to_date.to_s
  			attributes = attributes_for(:user_with_password, born_on: dob)
				post '/api/users', {user: attributes}, version_header
	      expect(response.status).to eq(201)
	      response_user_id = JSON.parse(response.body)['id']
	      check_user = User.find(response_user_id)
				expect(check_user.email).to eq(attributes[:email])
				expect(check_user.avatar_url.present?).to eq(true)
				expect(check_user.born_on.to_s).to eq(dob)
				expect(response.body).to have_json_path("id")
				expect(response.body).to have_json_path("fullname")
				expect(response.body).to have_json_path("avatar_url")
				expect(response.body).to have_json_path("auth_token")
  		end
	  end

	  context 'with valid attributes' do
	  	context "and facebook details" do
	  		it "should create user" do
	  			attributes = attributes_for(:user_with_out_password)
	  			attributes[:social_ids_attributes] = [attributes_for(:facebook_social_id)]
					post '/api/users', {user: attributes}, version_header
		      expect(response.status).to eq(201)
		      response_user_id = JSON.parse(response.body)['id']
		      check_user = User.find(response_user_id)
					expect(check_user.social_ids.size).to eq(1)
					check_user.social_ids.first.as_json(only: [])
	  		end
	  	end
	  end
  end

end
