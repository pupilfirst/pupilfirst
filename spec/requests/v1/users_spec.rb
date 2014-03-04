require 'spec_helper'

describe V1::UsersController do
	include V1ApiSpecHelper

  describe "GET on user" do
  	context "fetches details of user when id is provided" do
	    xit "returns http success with details" do
	    	user = create(:user_with_out_password)
	      get "/api/users/#{user.id}", {}, version_header
	      expect(response).to be_success
	    end
	  end
  end

  describe "POST on user" do

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

  end

end
