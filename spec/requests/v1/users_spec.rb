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
        let(:startup) { create :startup }
        before(:each) do
          get "/api/users/self", {}, version_header(startup.founders.first)
        end
        it "should have incorporation enabled, message nil" do
          expect(parse_json(response.body, 'startup_meta_details/incorporation/is_enabled')).to eq(false)
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
        let(:startup) { startup = create :startup }
        before(:each) do
          startup.founders.each do |f|
            f.update_attributes!(
              address: create(:address),
              father: create(:name),
            )
          end
          get "/api/users/self", {}, version_header(startup.founders.first)
        end
        it "should have incorporation enabled" do
          expect(parse_json(response.body, 'startup_meta_details/incorporation/is_enabled')).to eq(true)
          expect(parse_json(response.body, 'startup_meta_details/incorporation/message')).to eq(nil)
        end

        it "should have personal_info enabled with a message" do
          expect(parse_json(response.body, 'startup_meta_details/personal_info/is_enabled')).to eq(true)
          expect(parse_json(response.body, 'startup_meta_details/personal_info/message')).to be_kind_of String
        end
      end

      context 'one of the founders submits incorporation' do
        let(:startup) { create :startup }
        before(:each) do
          startup.update_attributes!(attributes_for(:incorporation))
        end
        context 'and is not yet approved' do
          before(:each) do
            startup.update_attributes!(incorporation_status: false)
          end
          context 'when personal info is not submited' do
            it "it should be enabled" do
              get "/api/users/self", {}, version_header(startup.founders.first)
              expect(parse_json(response.body, 'startup_meta_details/personal_info/is_enabled')).to eq(true)
              expect(parse_json(response.body, 'startup_meta_details/personal_info/message')).to be(nil)
            end
          end

          context 'users personal info is submited' do
            before(:each) do
              startup.founders.each do |f|
                f.update_attributes!(
                  address: create(:address),
                  father: create(:name),
                )
              end
            end
            it "it should display message to bring docs" do
              get "/api/users/self", {}, version_header(startup.founders.first)
              expect(parse_json(response.body, 'startup_meta_details/personal_info/is_enabled')).to eq(true)
              expect(parse_json(response.body, 'startup_meta_details/personal_info/message')).to be_kind_of String
            end
          end
        end

        context 'and is approved' do
          before(:each) do
            startup.update_attributes!(incorporation_status: true)
          end
          it "personal_info should not be enabled" do
            get "/api/users/self", {}, version_header(startup.founders.first)
            expect(parse_json(response.body, 'startup_meta_details/personal_info/is_enabled')).to eq(false)
          end
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

  describe 'POST /api/users' do
    let(:dob) { Time.parse('2000-5-5').to_date }

    context 'when the user already exists' do
      let(:startup) { create :startup }
      let(:attributes) { attributes_for(:user_with_password, born_on: dob.to_s, email: 'james.p.sullivan@mobme.in') }

      context 'when the user has an invitation token' do
        it 'updates the user entry' do
          user = User.create(
            email: 'james.p.sullivan@mobme.in',
            password: SecureRandom.hex,
            pending_startup_id: startup.id,
            invitation_token: SecureRandom.hex
          )

          post '/api/users', { user: attributes }, version_header
          user.reload
          expect(user.born_on).to eq dob
          expect(user.invitation_token).to eq nil
        end
      end

      context 'when the user has no invitation token' do
        it 'responds with error code AlreadyCreatedUser' do
          user = create :user_with_out_password, email: 'james.p.sullivan@mobme.in'
          post '/api/users', { user: attributes }, version_header
          expect(response.code).to eq '422'
          expect(parse_json response.body, 'code').to eq 'AlreadyCreatedUser'
        end
      end
    end

    context 'with valid attributes and valid password' do
      let(:attributes) { attributes_for(:user_with_password, born_on: dob.to_s) }

      it 'should create user' do
        post '/api/users', { user: attributes }, version_header
        expect(response.status).to eq(201)
        response_user_id = JSON.parse(response.body)['id']
        check_user = User.find(response_user_id)
        expect(check_user.email).to eq(attributes[:email])
        expect(check_user.avatar_url.present?).to eq(true)
        expect(check_user.born_on).to eq(dob)
        expect(response.body).to have_json_path('id')
        expect(response.body).to have_json_path('fullname')
        expect(response.body).to have_json_path('avatar_url')
        expect(response.body).to have_json_path('auth_token')
      end
    end

    context 'with invalid password' do
      it 'return bad_request with errors in body' do
        attributes = attributes_for(:user_with_password, born_on: dob.to_s).merge(password: 'foo')
        post '/api/users', { user: attributes }, version_header
        expect(response.status).to eq(400)
        expect(response.body).to have_json_path('error')
      end
    end
  end

  describe "PUT on user" do
    context 'user pan details are passed' do
      it "should update details" do
        @user = create :founder
        attributes = attributes_for(:director).merge({
          address_attributes: attributes_for(:address),
          father_attributes: attributes_for(:name),
          guardian_attributes: {
            name_attributes: attributes_for(:name),
            address_attributes: attributes_for(:address)
          }
        })
        put '/api/users/self', { user: attributes }, version_header(@user)
        expect(response.body).to have_json_path("message")
      end

      it "should apply for pan &/or din"
    end
  end

  describe 'POST /api/users/self/phone_number_verification' do
    let(:test_sms_provider) { 'http://mobme.in/sms/endpoint' }
    let(:user) { create :user_with_password }

    before do
      APP_CONFIG[:sms_provider_url] = test_sms_provider
      stub_request(:post, test_sms_provider)
    end

    after do
      APP_CONFIG[:sms_provider_url] = ENV['SMS_PROVIDER_URL']
    end

    context 'when the phone number is invalid' do
      it 'renders 422 InvalidPhoneNumber' do
        post '/api/users/self/phone_number', { phone: '6547982' }, version_header(user)
        expect(response.code).to eq '422'
        expect(parse_json response.body, 'code').to eq 'InvalidPhoneNumber'
      end
    end

    it 'renders nothing' do
      post '/api/users/self/phone_number', { phone: '919876543210' }, version_header(user)
      expect(response.code).to eq '200'
    end

    it 'stores phone number and verification code' do
      post '/api/users/self/phone_number', { phone: '9876543210' }, version_header(user)
      user.reload
      expect(user.phone).to eq '919876543210'
      expect(user.phone_verified).to eq false
      expect(user.phone_verification_code).to match_regex(/^\d{6}$/)
    end

    it 'sends a verification code to incoming requested phone number' do
      post '/api/users/self/phone_number', { phone: '+919876543210' }, version_header(user)

      expect(
        a_request(:post, test_sms_provider).with { |req|
          (req.body =~ /text=.*[\d{6}]/) && (req.body =~ /msisdn=919876543210/)
        }
      ).to have_been_made
    end
  end

  describe 'PUT /api/users/self/phone_number_verification' do
    let(:user) { create :user_with_password, phone: '+919876543210', phone_verification_code: '123456' }

    context 'when the phone number is invalid' do
      it 'renders 422 InvalidPhoneNumber' do
        put '/api/users/self/phone_number', { phone: 'foobar', code: '123456' }, version_header(user)
        expect(response.code).to eq '422'
        expect(parse_json response.body, 'code').to eq 'InvalidPhoneNumber'
      end
    end

    context 'when phone number does not match stored number' do
      it 'renders a 422 error' do
        put '/api/users/self/phone_number', { phone: '+911234567890', code: '213654' }, version_header(user)
        expect(response.code).to eq '422'
      end
    end

    context 'when phone number matches stored number' do
      context 'when the verification code is incorrect' do
        it 'renders a 422 error' do
          put '/api/users/self/phone_number', { phone: '+919876543210', code: 'WRONG_CODE' }, version_header(user)
          expect(response.code).to eq '422'
        end
      end

      context 'when the verification code is correct' do
        it 'sets phone number to verified' do
          put '/api/users/self/phone_number', { phone: '+919876543210', code: '123456' }, version_header(user)
          user.reload
          expect(user.phone_verified?).to eq true
          expect(user.phone_verification_code).to eq nil
        end

        it 'renders 200' do
          put '/api/users/self/phone_number', { phone: '+919876543210', code: '123456' }, version_header(user)
          expect(response.code).to eq '200'
        end
      end
    end
  end

  describe 'PUT /api/users/self/cofounder_invitation' do
    let(:user) { create :user_with_password }

    before do
      UserPushNotifyJob.stub_chain(:new, :async, perform_batch: true) # TODO: Change this to allow statement in Rspec v3.
    end

    context 'when user does not have pending invitation' do
      it 'responds with error code UserHasNoPendingStartupInvite' do
        put '/api/users/self/cofounder_invitation', {}, version_header(user)
        expect(parse_json(response.body, 'code')).to eq 'UserHasNoPendingStartupInvite'
        expect(response.code).to eq '404'
      end
    end

    context 'when user has pending invitation' do
      let(:startup) { create :startup }
      let(:user) { create :user_with_password, pending_startup_id: startup.id }

      it "sets user's startup to pending_startup_id and wipes pending_startup_id" do
        put '/api/users/self/cofounder_invitation', {}, version_header(user)
        expect(response.code).to eq '200'

        user.reload
        expect(user.startup_id).to eq startup.id
        expect(user.pending_startup_id).to eq nil
      end

      it 'adds the user to the list of founders on the startup' do
        put '/api/users/self/cofounder_invitation', {}, version_header(user)

        startup.reload
        expect(startup.founders).to include(user)
      end
    end
  end

  describe 'DELETE /api/users/self/cofounder_invitation' do
    let(:user) { create :user_with_password }

    before do
      UserPushNotifyJob.stub_chain(:new, :async, perform_batch: true) # TODO: Change this to allow statement in Rspec v3.
    end

    context 'when user does not have pending invitation' do
      it 'responds with error code UserHasNoPendingStartupInvite' do
        delete '/api/users/self/cofounder_invitation', {}, version_header(user)
        expect(parse_json(response.body, 'code')).to eq 'UserHasNoPendingStartupInvite'
        expect(response.code).to eq '404'
      end
    end

    context 'when user has pending invitation' do
      let(:startup) { create :startup }
      let(:user) { create :user_with_password, pending_startup_id: startup.id }

      it 'clears pending_startup_id' do
        delete '/api/users/self/cofounder_invitation', {}, version_header(user)
        expect(response.code).to eq '200'

        user.reload
        expect(user.pending_startup_id).to eq nil
      end
    end
  end

  describe 'POST /api/users/self/contacts' do
    let(:user) { create :user_with_password }

    context 'when a bad phone number is supplied' do
      it 'responds with 422 InvalidPhoneNumber' do
        post '/api/users/self/contacts', { user: { phone: '123456', fullname: 'Mike Wazowski' } }, version_header(user)
        expect(response.code).to eq '422'
        expect(parse_json response.body, 'code').to eq 'InvalidPhoneNumber'
      end
    end

    it 'creates user as a contact' do
      post '/api/users/self/contacts', { user: { phone: '+919876543210', fullname: 'Mike Wazowski', company: 'Monsters, Inc.', designation: 'Scarer' } }, version_header(user)
      expect(response).to be_success
      last_user = User.last
      expect(last_user.is_contact).to be_true
      expect(last_user.fullname).to eq 'Mike Wazowski'
      expect(last_user.company).to eq 'Monsters, Inc.'
      expect(last_user.designation).to eq 'Scarer'
      expect(last_user.phone).to eq '919876543210'
    end

    it 'creates a connection between current user and contact' do
      post '/api/users/self/contacts', { user: { phone: '9876543210', fullname: 'Mike Wazowski' } }, version_header(user)
      user_connections = user.connections.includes(:contact)
      expect(user_connections.last.contact.id).to eq User.last.id
    end
  end

  describe 'GET /api/users/self/contacts' do
    let(:user) { create :user_with_out_password }
    let!(:contact_1) { create :user_as_contact }
    let!(:contact_2) { create :user_as_contact }
    let!(:contact_3) { create :user_as_contact }

    before do
      UserPushNotifyJob.stub_chain(:new, :async, :perform)
    end

    it 'returns all connections supplied by SV to user' do
      create :connection, user: user, contact: contact_1, direction: Connection::DIRECTION_SV_TO_USER
      create :connection, user: user, contact: contact_2, direction: Connection::DIRECTION_USER_TO_SV
      create :connection, user: user, contact: contact_3, direction: Connection::DIRECTION_SV_TO_USER

      get '/api/users/self/contacts', {}, version_header(user)

      expect((parse_json response.body).length).to eq 2
      expect(parse_json response.body, '0/fullname').to eq contact_1.fullname
      expect(parse_json response.body, '1/fullname').to eq contact_3.fullname
    end
  end
end
