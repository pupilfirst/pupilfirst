require "spec_helper"

describe "Startup Requests" do
  include V1ApiSpecHelper
  include UserSpecHelper
  include Rails.application.routes.url_helpers

  let!(:startup ) { create(:startup, {approval_status: true,  name: 'startup 1'}) }
  let!(:startup1) { create(:startup, {approval_status: true,  name: 'startup 2'}) }
  let!(:startup2) { create(:startup, {approval_status: true,  name: 'foobar 1'}) }
  let!(:startup3) { create(:startup, {approval_status: true,  name: 'foobar 2'}) }

  it "fetch startups on index" do
    get "/api/startups", {},version_header
    expect(response).to render_template(:index)
    response.body.should have_json_path("0/id")
    response.body.should have_json_path("0/name")
    response.body.should have_json_path("0/logo_url")
    response.body.should have_json_path("0/pitch")
    response.body.should have_json_path("0/website")
    response.body.should have_json_path("0/created_at")
  end

  it "fetch startups within a category" do
    get "/api/startups", {category: startup1.categories.first.name},version_header
    expect(response).to render_template(:index)
    response.body.should have_json_size(1).at_path("/")
    response.body.should have_json_path("0/id")
    response.body.should have_json_path("0/name")
    response.body.should have_json_path("0/logo_url")
    response.body.should have_json_path("0/pitch")
    response.body.should have_json_path("0/website")
    response.body.should have_json_path("0/created_at")
  end

  it "fetches related startups when searched for" do
    get "/api/startups", {search_term: 'foobar'}, version_header
    expect(response).to render_template(:index)
    response.body.should have_json_size(2).at_path("/")
    response.body.should have_json_path("0/id")
    response.body.should have_json_path("0/name")
    response.body.should have_json_path("0/logo_url")
    response.body.should have_json_path("0/pitch")
    response.body.should have_json_path("0/website")
    response.body.should have_json_path("0/created_at")
  end

  it "fetches one startup with " do
    get "/api/startups/#{startup.id}", {}, version_header
    expect(response).to render_template(:show)
    response.body.should have_json_path("id")
    response.body.should have_json_path("name")
    response.body.should have_json_path("logo_url")
    response.body.should have_json_path("pitch")
    response.body.should have_json_path("website")
    response.body.should have_json_path("about")
    response.body.should have_json_path("email")
    response.body.should have_json_path("phone")
    response.body.should have_json_path("twitter_link")
    response.body.should have_json_path("facebook_link")
    response.body.should have_json_type(Array).at_path("categories")
    response.body.should have_json_type(Array).at_path("founders")
    response.body.should have_json_path("founders/0/id")
    response.body.should have_json_path("founders/0/name")
    response.body.should have_json_path("founders/0/title")
    response.body.should have_json_path("founders/0/picture_url")
    response.body.should have_json_path("founders/0/linkedin_url")
    response.body.should have_json_path("founders/0/twitter_url")
  end

  it "POST startup" do
    post "/api/startups", {startup: attributes_for(:startup_application)}, version_header
    expect(response).to be_success
    have_user_object(response, 'user')
  end

  it "fetches suggestions based on given term" do
    get "/api/startups/load_suggestions", {term: 'fo'}, version_header
    expect(response.body).to have_json_size(2).at_path("/")
    expect(response.body).to have_json_path("0/id")
    expect(response.body).to have_json_path("0/name")
    expect(response.body).to have_json_path("0/logo_url")
  end

  context "request to add new founder to a startup" do
    let(:startup) { create :startup}
    let(:new_employee) { create :user_with_out_password}

    before(:each) do
      ActionMailer::Base.deliveries = []
      UserPushNotifyJob.stub_chain(:new, :async, perform: true) # TODO: Change this to allow statement in Rspec v3.
    end

    it "raise error if auth_token is not given" do
      expect { post "/api/startups/#{startup.id}/link_employee", {employee_id: new_employee.id}, {} }.to raise_error(RuntimeError)
    end

    it "sends email to all existing co-founders" do
      post "/api/startups/#{startup.id}/link_employee", {position: 'startup ceo'}, version_header(new_employee)
      new_employee.reload
      expect(emails_sent.last.body.to_s).to include(confirm_employee_startup_url(startup, token: new_employee.startup_verifier_token))
      expect(new_employee.startup_link_verifier_id).to eql(nil)
      expect(new_employee.title).to eql('startup ceo')
      expect(new_employee.reload.startup_id).to eql(startup.id)
      expect(response).to be_success
      have_user_object(response, 'user')
    end

    def emails_sent
      ActionMailer::Base.deliveries
    end
  end
end
