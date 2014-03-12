require 'spec_helper'

describe V1::UsersController do
	include V1ApiSpecHelper

  shared_examples "applicaiton process status for" do |process_name|
    context process_name do
      context "user filling up the applicaiton" do
        context 'not submited' do
          xit "should be nil" do

          end
        end
        context 'submited and pending' do
          xit "should have status false" do

          end
        end
        context 'submited and completed' do
          xit "should have status true" do

          end
        end
      end

      context "user has been assigned as director of startups" do
        xit "should set #{process_name} status/message as nil" do

        end
      end
    end
  end

  describe "GET on user" do
  	context "fetches details of user when id is provided" do
	    xit "returns http success with details" do
	    	user = create(:user_with_out_password)
	      get "/api/users/#{user.id}", {}, version_header
	      expect(response).to be_success
	    end

	  end

    context 'when id is self' do
      it "returns extra details about related startups" do
        get "/api/users/self", {}, version_header
        expect(response).to be_success
        check_path(response, "startup_meta_details/approval_status")
        check_path(response, "startup_meta_details/next_process")
        check_path(response, "startup_meta_details/incorporation")
        check_path(response, "startup_meta_details/incorporation/status")
        check_path(response, "startup_meta_details/incorporation/is_enabled")
        check_path(response, "startup_meta_details/incorporation/message")
        check_path(response, "startup_meta_details/banking")
        check_path(response, "startup_meta_details/banking/status")
        check_path(response, "startup_meta_details/banking/is_enabled")
        check_path(response, "startup_meta_details/banking/message")
        check_path(response, "startup_meta_details/sep")
        check_path(response, "startup_meta_details/sep/status")
        check_path(response, "startup_meta_details/sep/is_enabled")
        check_path(response, "startup_meta_details/sep/message")
        check_path(response, "startup_meta_details/personal_info")
        check_path(response, "startup_meta_details/personal_info/is_enabled")
        check_path(response, "startup_meta_details/personal_info/status")
        check_path(response, "startup_meta_details/personal_info/message")
      end

      it_behaves_like "applicaiton process status for", 'incorporation'
      it_behaves_like "applicaiton process status for", 'banking'
      it_behaves_like "applicaiton process status for", 'SEP'
      it_behaves_like "applicaiton process status for", 'personal_info'

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

    context 'with invalid password' do
      it "return bad_request with errors in body" do
        dob = Time.parse('2000-5-5').to_date.to_s
        attributes = attributes_for(:user_with_password, born_on: dob).merge(password: 'foo')
        post '/api/users', {user: attributes}, version_header
        expect(response.status).to eq(400)
        expect(response.body).to have_json_path("error")
      end
    end
  end

  describe "PUT on user" do
    context 'user pan details are passed' do
      xit "should update details" do

      end

      xit "should apply for pan &/or din " do

      end
    end
  end
end
