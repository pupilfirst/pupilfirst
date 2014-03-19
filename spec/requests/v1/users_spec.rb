require 'spec_helper'

describe V1::UsersController do
	include V1ApiSpecHelper
  include JsonSpec::Helpers
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
        @startup = create :startup
        get "/api/users/self", {}, version_header(@startup.founders.first)
        expect(response).to be_success
        check_path(response, "startup_meta_details/approval_status")
        check_path(response, "startup_meta_details/incorporation")
        check_path(response, "startup_meta_details/incorporation/is_enabled")
        check_path(response, "startup_meta_details/incorporation/message")
        check_path(response, "startup_meta_details/banking")
        check_path(response, "startup_meta_details/banking/is_enabled")
        check_path(response, "startup_meta_details/banking/message")
        check_path(response, "startup_meta_details/sep")
        check_path(response, "startup_meta_details/sep/is_enabled")
        check_path(response, "startup_meta_details/sep/message")
        check_path(response, "startup_meta_details/personal_info")
        check_path(response, "startup_meta_details/personal_info/is_enabled")
        check_path(response, "startup_meta_details/personal_info/message")
      end

      context "when startup is just created" do
        before(:all) do
          @startup = create :startup
          get "/api/users/self", {}, version_header(@startup.founders.first)
        end
        it "should have incorporation enabled, message nil" do
          expect(parse_json(response.body, 'startup_meta_details/incorporation/is_enabled')).to eq(true)
          expect(parse_json(response.body, 'startup_meta_details/incorporation/message')).to eq(nil)
        end

        it "should have banking disabled" do
          expect(parse_json(response.body, 'startup_meta_details/banking/is_enabled')).to eq(false)
          expect(parse_json(response.body, 'startup_meta_details/banking/message')).to eq(nil)
        end
        it "should have personal_info enabled" do
          expect(parse_json(response.body, 'startup_meta_details/personal_info/is_enabled')).to eq(true)
          expect(parse_json(response.body, 'startup_meta_details/personal_info/message')).to eq(nil)
        end
      end

      context "profileinfo is submited" do
        before(:all) do
          @startup = create :startup
          @founder = @startup.founders.each do |f|
            f.update_attributes!(
                                 address: create(:address),
                                 father: create(:name),
                                )
          end
          get "/api/users/self", {}, version_header(@startup.founders.first)
        end
        it "should have incorporation enabled" do
          expect(parse_json(response.body, 'startup_meta_details/incorporation/is_enabled')).to eq(true)
          expect(parse_json(response.body, 'startup_meta_details/incorporation/message')).to eq(nil)
        end

        it "should have personal_info disabled" do
          expect(parse_json(response.body, 'startup_meta_details/personal_info/is_enabled')).to eq(false)
        end
      end

      context "all director's info is completed" do
        let(:startup) { create :startup }
        before(:each) do
          startup.founders.each do |f|
            f.update_attributes!(
                                 address: create(:address),
                                 father: create(:name),
                                )
          end
        end

        it "should have personal_info disabled" do
          get "/api/users/self", {}, version_header(startup.founders.first)
          expect(parse_json(response.body, 'startup_meta_details/personal_info/is_enabled')).to eq(false)
        end

        context "incorporation is submited" do
          before(:each) do
            startup.update_attributes!(attributes_for(:incorporation))

            get "/api/users/self", {}, version_header(startup.founders.first)
          end
          it "should have banking enabled" do
            expect(parse_json(response.body, 'startup_meta_details/banking/is_enabled')).to eq(true)
            expect(parse_json(response.body, 'startup_meta_details/banking/message')).to eq(nil)
          end

          context 'and approved' do
            before(:each) do
              startup.update_attributes!(incorporation_status: true)
            end
            it "should have incorporation disabled" do
              get "/api/users/self", {}, version_header(startup.founders.first)
              expect(parse_json(response.body, 'startup_meta_details/incorporation/is_enabled')).to eq(false)
            end
          end

          context 'and pending' do
            it "should have incorporation enabled, with a message" do
              get "/api/users/self", {}, version_header(startup.founders.first)
              expect(parse_json(response.body, 'startup_meta_details/incorporation/is_enabled')).to eq(true)
              expect(response.body).to have_json_type(String).at_path('startup_meta_details/incorporation/message')
            end
          end
        end

        context "incorporation is submited/approved" do
          before(:each) do
            startup.update_attributes!(attributes_for(:incorporation))
          end
          context "banking is pending" do
            before(:each) do
              create :bank, startup: startup, directors: startup.founders
            end

            it "and should be enabled" do
              get "/api/users/self", {}, version_header(startup.founders.first)
              expect(parse_json(response.body, 'startup_meta_details/banking/is_enabled')).to eq(true)
              expect(parse_json(response.body, 'startup_meta_details/banking/message')).to be_kind_of(String)
            end
          end

          context 'banking is approved' do
            before(:each) do
              create :bank, startup: startup, directors: startup.founders
              startup.update_attributes!(bank_status: true)
            end

            it "should be disabled" do
              get "/api/users/self", {}, version_header(startup.founders.first)
              expect(parse_json(response.body, 'startup_meta_details/banking/is_enabled')).to eq(false)
            end

          end
        end

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
      it "should update details" do
        @user = create :founder
        attributes = attributes_for(:director).merge({
          other_name_attributes: attributes_for(:name),
          address_attributes: attributes_for(:address),
          father_attributes: attributes_for(:name),
          guardian_attributes: {
            name_attributes: attributes_for(:name),
            address_attributes: attributes_for(:address)
          }
        })
        put '/api/users/self', { user: attributes}, version_header(@user)
        expect(response.body).to have_json_path("message")
      end

      it "should apply for pan &/or din"
    end
  end
end
